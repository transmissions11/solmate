// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC1155} from "./utils/mocks/MockERC1155.sol";

contract ERC1155Test is DSTestPlus {
    MockERC1155 token;

    function setUp() public {
        token = new MockERC1155();
    }

    function testSupportsERC165Interface() public {
        // assertTrue(token.supportsInterface(0x01ffc9a7));
        // assertTrue(token.supportsInterface(0xd9b67a26));
    }

    // TODO:
}
