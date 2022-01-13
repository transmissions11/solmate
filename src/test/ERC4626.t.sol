// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626} from "./utils/mocks/MockERC4626.sol";
import {ERC4626User} from "./utils/users/ERC4626User.sol";

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

    function testAtomicDepositWithdraw() public {
        // uint256 amount = fuzzAmount / 10**underlying.decimals();
        uint256 amount = 2e18;

        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        vault.deposit(address(this), amount);

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

    function testAtomicDepositRedeem() public {
        // uint256 amount = fuzzAmount / 10**underlying.decimals();
        uint256 amount = 2e18;

        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        vault.deposit(address(this), amount);

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
