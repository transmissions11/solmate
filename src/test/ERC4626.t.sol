// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626} from "./utils/mocks/MockERC4626.sol";
import {ERC4626User} from "./utils/users/ERC4626User.sol";

// TODO: verify hooks are being called
// TODO: implement fuzzing for tests where applicable
// TODO: think of if there are any invariants and how you would implement them
// TODO: fix mint implementation
// TODO: implement more complex scenario where part of the tokens are redeemed or withdrawn

contract ERC4626Test is DSTestPlus {
    MockERC20 underlying;
    MockERC4626 vault;

    function setUp() public {
        underlying = new MockERC20("Mock Token", "TKN", 18);
        vault = new MockERC4626(underlying, "Mock Token Vault", "vwTKN");
    }

    function invariantMetadata() public {
        assertEq(vault.name(), "Mock Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testMetaData() public {
        assertEq(vault.name(), "Mock Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testSingleDepositWithdraw() public {
        uint256 aliceUnderlyingAmount = 10e18;

        ERC4626User alice = new ERC4626User(vault, underlying);

        underlying.mint(address(alice), aliceUnderlyingAmount);
        alice.approve(address(vault), aliceUnderlyingAmount);
        assertEq(underlying.allowance(address(alice), address(vault)), aliceUnderlyingAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(address(alice));

        uint256 aliceShareAmount = alice.deposit(address(alice), aliceUnderlyingAmount);

        // Expect exchange rate to be 1:1 on initial deposit
        assertEq(aliceUnderlyingAmount, aliceShareAmount);
        assertEq(vault.calculateUnderlying(aliceShareAmount), aliceUnderlyingAmount);
        assertEq(vault.calculateShares(aliceUnderlyingAmount), aliceShareAmount);
        assertEq(vault.totalSupply(), aliceShareAmount);
        assertEq(vault.totalUnderlying(), aliceUnderlyingAmount);
        assertEq(vault.balanceOf(address(alice)), aliceUnderlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceUnderlyingAmount);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal - aliceUnderlyingAmount);

        alice.withdraw(address(alice), address(alice), aliceUnderlyingAmount);

        assertEq(vault.totalUnderlying(), 0);
        assertEq(vault.balanceOf(address(alice)), 0);
        assertEq(vault.balanceOfUnderlying(address(alice)), 0);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal);
    }

    function testSingleMintRedeem() public {
        uint256 aliceShareAmount = 10e18;

        ERC4626User alice = new ERC4626User(vault, underlying);

        underlying.mint(address(alice), aliceShareAmount);
        alice.approve(address(vault), aliceShareAmount);
        assertEq(underlying.allowance(address(alice), address(vault)), aliceShareAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(address(alice));

        uint256 aliceUnderlyingAmount = alice.mint(address(alice), aliceShareAmount);

        // Expect exchange rate to be 1:1 on initial mint
        assertEq(aliceShareAmount, aliceUnderlyingAmount);
        assertEq(vault.calculateUnderlying(aliceShareAmount), aliceUnderlyingAmount);
        assertEq(vault.calculateShares(aliceUnderlyingAmount), aliceShareAmount);
        assertEq(vault.totalSupply(), aliceShareAmount);
        assertEq(vault.totalUnderlying(), aliceUnderlyingAmount);
        assertEq(vault.balanceOf(address(alice)), aliceUnderlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceUnderlyingAmount);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal - aliceUnderlyingAmount);

        alice.redeem(address(alice), address(alice), aliceShareAmount);

        assertEq(vault.totalUnderlying(), 0);
        assertEq(vault.balanceOf(address(alice)), 0);
        assertEq(vault.balanceOfUnderlying(address(alice)), 0);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal);
    }

    function testMultipleAtomicScenario() public {
        // Scenario:
        // - Alice mints 2e18 tokens
        // - Bob deposits 4e18 tokens
        // - Vault mutates by +3e18 tokens (simulated yield returned from strategy)
        // - Alice redeems 2e18 tokens + 1e18 tokens (33.33%)
        // - Bob redeems 4e18 tokens + 2e18 tokens (66.66%)

        ERC4626User alice = new ERC4626User(vault, underlying);
        ERC4626User bob = new ERC4626User(vault, underlying);

        uint256 aliceDesiredShareAmount = 2e18;
        uint256 bobDesiredUnderlyingAmount = 4e18;
        uint256 mutationUnderlyingAmount = 3e18;

        underlying.mint(address(alice), 2e18);
        alice.approve(address(vault), 2e18);
        assertEq(underlying.allowance(address(alice), address(vault)), 2e18);

        underlying.mint(address(bob), 4e18);
        bob.approve(address(vault), 4e18);
        assertEq(underlying.allowance(address(bob), address(vault)), 4e18);

        // Alice mints
        uint256 aliceUnderlyingAmount = alice.mint(address(alice), aliceDesiredShareAmount);
        uint256 aliceShareAmount = vault.calculateShares(aliceUnderlyingAmount);

        // Expect to have received the requested mint amount
        assertEq(aliceShareAmount, aliceDesiredShareAmount);
        assertEq(vault.balanceOf(address(alice)), aliceShareAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceUnderlyingAmount);

        // Expect a 1:1 ratio before mutation
        assertEq(aliceUnderlyingAmount, aliceDesiredShareAmount);

        // Sanity check
        assertEq(vault.totalSupply(), aliceShareAmount);
        assertEq(vault.totalUnderlying(), aliceUnderlyingAmount);

        // Bob deposits
        uint256 bobShareAmount = bob.deposit(address(bob), bobDesiredUnderlyingAmount);
        uint256 bobUnderlyingAmount = vault.calculateUnderlying(bobShareAmount);

        // Expect to have received the requested underlying amount
        assertEq(bobUnderlyingAmount, bobDesiredUnderlyingAmount);
        assertEq(vault.balanceOf(address(bob)), bobShareAmount);
        assertEq(vault.balanceOfUnderlying(address(bob)), bobUnderlyingAmount);

        // Expect a 1:1 ratio before mutation
        assertEq(bobShareAmount, bobUnderlyingAmount);

        // Sanity check
        uint256 preMutationShareBal = aliceShareAmount + bobShareAmount;
        uint256 preMutationBal = aliceUnderlyingAmount + bobUnderlyingAmount;
        assertEq(vault.totalSupply(), preMutationShareBal);
        assertEq(vault.totalUnderlying(), preMutationBal);

        // Simulate a positive mutation (+3e18) within the vault.
        // The vault now contains more tokens than deposited which causes the exchangeRatio to change.
        // Alice share is 33.33% of the vault, Bob 66.66% of the vault.
        // Alice's share count stays the same but the underlying amount changes from 2e18 to 3e18.
        // Bob's share count stays the same but the underlying amount changes from 4e18 to 6e183.
        underlying.mint(address(vault), mutationUnderlyingAmount);
        assertEq(vault.totalSupply(), preMutationShareBal);
        assertEq(vault.totalUnderlying(), preMutationBal + mutationUnderlyingAmount);
        assertEq(vault.balanceOf(address(alice)), aliceShareAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceUnderlyingAmount + (mutationUnderlyingAmount / 3) * 1);
        assertEq(vault.balanceOf(address(bob)), bobShareAmount);
        assertEq(vault.balanceOfUnderlying(address(bob)), bobUnderlyingAmount + (mutationUnderlyingAmount / 3) * 2);

        // Alice redeems her share balance
        uint256 aliceRedeemUnderlyingAmount = alice.redeem(address(alice), address(alice), aliceShareAmount);
        assertEq(aliceRedeemUnderlyingAmount, aliceUnderlyingAmount + (mutationUnderlyingAmount / 3) * 1);
        assertEq(vault.balanceOf((address(alice))), 0);
        assertEq(vault.balanceOfUnderlying((address(alice))), 0);
        assertEq(vault.totalSupply(), preMutationShareBal - aliceShareAmount);
        assertEq(vault.totalUnderlying(), preMutationBal + mutationUnderlyingAmount - aliceRedeemUnderlyingAmount);

        // Bob withdraws his share balance (share balance remains the same)
        assertEq(vault.balanceOfUnderlying(address(bob)), bobUnderlyingAmount + (mutationUnderlyingAmount / 3) * 2);
        assertEq(vault.balanceOf(address(bob)), bobShareAmount);
        uint256 bobWithdrawShareAmount = bob.withdraw(
            address(bob),
            address(bob),
            bobUnderlyingAmount + (mutationUnderlyingAmount / 3) * 2
        );
        assertEq(bobWithdrawShareAmount, bobShareAmount);
        assertEq(vault.balanceOf((address(bob))), 0);
        assertEq(vault.balanceOfUnderlying((address(bob))), 0);

        // Alice and Bob left the vault, should be empty again
        assertEq(vault.totalSupply(), 0);
        assertEq(vault.totalUnderlying(), 0);
    }

    function testUnderlyingSharesRatio(uint256 underlyingBalance) public {
        uint256 sharesBalance = vault.calculateShares(underlyingBalance);
        assertEq(vault.calculateUnderlying(sharesBalance), underlyingBalance);
        assertEq(vault.calculateShares(underlyingBalance), sharesBalance);
    }

    function testFailDepositWithNotEnoughApproval() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);
        assertEq(underlying.allowance(address(this), address(vault)), 0.5e18);

        vault.deposit(address(this), 1e18);
    }

    function testFailWithdrawWithNotEnoughUnderlyingAmount() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNotEnoughShareAmount() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailWithdrawWithNoUnderlyingAmount() public {
        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNoShareAmount() public {
        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailDepositWithNoApproval() public {
        vault.deposit(address(this), 1e18);
    }
}
