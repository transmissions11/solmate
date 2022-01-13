// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626} from "./utils/mocks/MockERC4626.sol";
import {ERC4626User} from "./utils/users/ERC4626User.sol";

// NOTE: dapp test -m ':ERC4626Test\.'
// NOTE: dapp test -m ':ERC4626Test\.testMultipleAtomicDepositWithdraw'

// TODO: verify hooks are being called
contract ERC4626Test is DSTestPlus {
    MockERC4626 vault;
    MockERC20 underlying;

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

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL TESTS
    //////////////////////////////////////////////////////////////*/

    function testSingleAtomicDepositWithdraw() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 amount = 2e18; // underlyingAmount

        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        uint256 shares = vault.deposit(address(this), amount);
        assertEq(shares, amount);

        assertEq(vault.totalHoldings(), amount);
        assertEq(vault.balanceOf(address(this)), amount);
        assertEq(vault.balanceOfUnderlying(address(this)), amount);
        assertEq(underlying.balanceOf(address(this)), preDepositBal - amount);

        vault.withdraw(address(this), address(this), amount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.balanceOfUnderlying(address(this)), 0);
        assertEq(underlying.balanceOf(address(this)), preDepositBal);
    }

    function testSingleAtomicMintWithdraw() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 shareAmount = 2e18; // shareAmount

        underlying.mint(address(this), shareAmount);
        underlying.approve(address(vault), shareAmount);

        // // Mint requires the returned amount
        uint256 underlyingAmount = vault.mint(address(this), shareAmount);
        assertEq(underlyingAmount, shareAmount);
        assertEq(vault.totalHoldings(), underlyingAmount);
    }

    function testMultipleAtomicDepositWithdraw() public {
        ERC4626User alice = new ERC4626User(vault, underlying);
        ERC4626User bob = new ERC4626User(vault, underlying);

        uint256 aliceAmount = 2e18;
        uint256 bobAmount = 3e18;

        underlying.mint(address(alice), aliceAmount);
        alice.approve(address(vault), aliceAmount);

        underlying.mint(address(bob), bobAmount);
        bob.approve(address(vault), bobAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(address(alice));
        uint256 bobPreDepositBal = underlying.balanceOf(address(bob));

        assertEq(alicePreDepositBal, aliceAmount);
        assertEq(bobPreDepositBal, bobAmount);
        assertEq(underlying.allowance(address(alice), address(vault)), aliceAmount);
        assertEq(underlying.allowance(address(bob), address(vault)), bobAmount);

        uint256 aliceShares = alice.deposit(address(alice), aliceAmount);
        assertEq(aliceShares, aliceAmount);

        assertEq(vault.totalHoldings(), aliceAmount);
        assertEq(vault.balanceOf(address(alice)), aliceAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceAmount);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal - aliceAmount);

        uint256 bobShares = bob.deposit(address(bob), bobAmount);
        assertEq(bobShares, bobAmount);

        assertEq(vault.totalHoldings(), aliceAmount + bobAmount);
        assertEq(vault.balanceOf(address(bob)), bobAmount);
        assertEq(vault.balanceOfUnderlying(address(bob)), bobAmount);
        assertEq(underlying.balanceOf(address(bob)), bobPreDepositBal - bobAmount);

        alice.withdraw(address(alice), address(alice), aliceAmount);

        assertEq(vault.totalHoldings(), bobAmount);
        assertEq(vault.balanceOf(address(alice)), 0);
        assertEq(vault.balanceOfUnderlying(address(alice)), 0);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal);

        bob.withdraw(address(bob), address(bob), bobAmount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(bob)), 0);
        assertEq(vault.balanceOfUnderlying(address(bob)), 0);
        assertEq(underlying.balanceOf(address(bob)), bobPreDepositBal);
    }

    function testSingleAtomicDepositRedeem() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 amount = 2e18;

        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        uint256 underlyingAmount = vault.deposit(address(this), amount);
        assertEq(underlyingAmount, amount);

        assertEq(vault.totalHoldings(), amount);
        assertEq(vault.balanceOf(address(this)), amount);
        assertEq(vault.balanceOfUnderlying(address(this)), amount);
        assertEq(underlying.balanceOf(address(this)), preDepositBal - amount);

        vault.redeem(address(this), address(this), amount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.balanceOfUnderlying(address(this)), 0);
        assertEq(underlying.balanceOf(address(this)), preDepositBal);
    }

    /*///////////////////////////////////////////////////////////////
                 DEPOSIT/WITHDRAWAL SANITY CHECK TESTS
    //////////////////////////////////////////////////////////////*/

    function testFailDepositWithNotEnoughApproval() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);
        assertEq(underlying.allowance(address(this), address(vault)), 0.5e18);

        vault.deposit(address(this), 1e18);
    }

    function testFailWithdrawWithNotEnoughBalance() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNotEnoughBalance() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNoBalance() public {
        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailWithdrawWithNoBalance() public {
        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailDepositWithNoApproval() public {
        vault.deposit(address(this), 1e18);
    }
}
