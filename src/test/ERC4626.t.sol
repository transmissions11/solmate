// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626} from "./utils/mocks/MockERC4626.sol";
import {ERC4626User} from "./utils/users/ERC4626User.sol";

contract ERC4626Test is DSTestPlus {
    MockERC20 underlying;
    MockERC4626 vault;

    function setUp() public {
        underlying = new MockERC20("Token", "TKN", 18);
        vault = new MockERC4626(underlying, "Token Vault", "vwTKN");
    }

    function invariantMetadata() public {
        assertEq(vault.name(), "Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testMetaData() public {
        assertEq(vault.name(), "Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testDeposit() public {
        ERC4626User usr = new ERC4626User(vault);
    }

    function testWithdraw() public {
        ERC4626User usr = new ERC4626User(vault);
    }
}
