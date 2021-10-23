// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockERC20} from "./utils/mocks/MockERC20.sol";

import {CREATE3} from "../utils/CREATE3.sol";

contract MinimalERC20 is MockERC20("Minimal ERC20", "ERC20", 18) {}

contract CREATE3Test is DSTestPlus {
    function testDeployERC20() public {
        bytes32 salt = keccak256(bytes("A salt!"));

        MinimalERC20 deployed = MinimalERC20(CREATE3.deploy(salt, type(MinimalERC20).creationCode));

        assertEq(address(deployed), CREATE3.getDeployed(salt));

        assertEq(deployed.name(), "Minimal ERC20");
        assertEq(deployed.symbol(), "ERC20");
        assertEq(deployed.decimals(), 18);
    }

    function testFailDoubleDeployERC20() public {
        bytes32 salt = keccak256(bytes("A salt!"));

        CREATE3.deploy(salt, type(MinimalERC20).creationCode);
        CREATE3.deploy(salt, type(MinimalERC20).creationCode);
    }

    function testDeployERC20(bytes32 salt) public {
        MinimalERC20 deployed = MinimalERC20(CREATE3.deploy(salt, type(MinimalERC20).creationCode));

        assertEq(address(deployed), CREATE3.getDeployed(salt));

        assertEq(deployed.name(), "Minimal ERC20");
        assertEq(deployed.symbol(), "ERC20");
        assertEq(deployed.decimals(), 18);
    }

    function testFailDoubleDeployERC20(bytes32 salt) public {
        CREATE3.deploy(salt, type(MinimalERC20).creationCode);
        CREATE3.deploy(salt, type(MinimalERC20).creationCode);
    }
}
