// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTestPlus {
    function testFMul() public {
        assertEq(FixedPointMathLib.fmul(2.5e27, 0.5e27, FixedPointMathLib.RAY), 1.25e27);
        assertEq(FixedPointMathLib.fmul(2.5e18, 0.5e18, FixedPointMathLib.WAD), 1.25e18);
        assertEq(FixedPointMathLib.fmul(2.5e8, 0.5e8, FixedPointMathLib.YAD), 1.25e8);
    }

    function testFDiv() public {
        assertEq(FixedPointMathLib.fdiv(1e27, 2e27, FixedPointMathLib.RAY), 0.5e27);
        assertEq(FixedPointMathLib.fdiv(1e18, 2e18, FixedPointMathLib.WAD), 0.5e18);
        assertEq(FixedPointMathLib.fdiv(1e8, 2e8, FixedPointMathLib.YAD), 0.5e8);
    }

    function testFPow() public {
        assertEq(FixedPointMathLib.fpow(2e27, 2, FixedPointMathLib.RAY), 4e27);
        assertEq(FixedPointMathLib.fpow(2e18, 2, FixedPointMathLib.WAD), 4e18);
        assertEq(FixedPointMathLib.fpow(2e8, 2, FixedPointMathLib.YAD), 4e8);
    }

    function testSqrt(uint256 x) public {
        uint256 root = FixedPointMathLib.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function testMin(uint256 x, uint256 y) public {
        if (x <= y) {
            assertEq(FixedPointMathLib.min(x, y), x);
        } else {
            assertEq(FixedPointMathLib.min(x, y), y);
        }
    }

    function testMax(uint256 x, uint256 y) public {
        if (x >= y) {
            assertEq(FixedPointMathLib.max(x, y), x);
        } else {
            assertEq(FixedPointMathLib.max(x, y), y);
        }
    }
}
