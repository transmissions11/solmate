// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {BitwiseLib} from "../utils/BitwiseLib.sol";

contract BitwiseLibTest is DSTestPlus {
    function testIlog() public {
        assertEq(BitwiseLib.ilog2(0), 0);
        for (uint256 i = 1; i < 255; i++) {
            assertEq(BitwiseLib.ilog2((1 << i) - 1), i - 1);
            assertEq(BitwiseLib.ilog2((1 << i)), i);
            assertEq(BitwiseLib.ilog2((1 << i) + 1), i);
        }
    }
}
