// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626Track} from "./utils/mocks/MockERC4626Track.sol";

contract ERC4626TrackTest is DSTestPlus {
    MockERC20 underlying;
    MockERC4626Track vault;

    function setUp() public {
        underlying = new MockERC20("Mock Token", "TKN", 18);
        vault = new MockERC4626Track(underlying, "Mock Token Track Vault", "vwTKN");
    }

    function testTrackandDonation() public {
        address alice = address(0xABCD);
        address bob = address(0xCDEF);

        underlying.mint(alice, 100);
        underlying.mint(bob, 100);

        hevm.startPrank(alice);
        underlying.approve(address(vault), 100);
        vault.deposit(100, alice);
        hevm.stopPrank();

        hevm.startPrank(bob);
        underlying.approve(address(vault), 100);
        vault.deposit(100, bob);
        hevm.stopPrank();

        // Donate to vault
        underlying.mint(address(vault), 100);

        // Redeem only tracked assets and not donated assets
        hevm.prank(alice);
        vault.redeem(100, alice, alice);
        hevm.prank(bob);
        vault.redeem(100, bob, bob);

        assertEq(vault.totalAssets(), 0);
        assertEq(underlying.balanceOf(address(vault)), 100);
    }
}
