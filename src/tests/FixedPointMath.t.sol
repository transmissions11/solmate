// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {FixedPointMath} from "../utils/FixedPointMath.sol";

contract FixedPointMathTest is DSTestPlus {
    function testFMul() public {
        assertEq(FixedPointMath.fmul(FixedPointMath.RAY, 2.5e27, 0.5e27), 1.25e27);
        assertEq(FixedPointMath.fmul(FixedPointMath.WAD, 2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMath.fmul(FixedPointMath.YAD, 2.5e8, 0.5e8), 1.25e8);
    }

    function testFDiv() public {
        assertEq(FixedPointMath.fdiv(FixedPointMath.RAY, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMath.fdiv(FixedPointMath.WAD, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMath.fdiv(FixedPointMath.YAD, 1e8, 2e8), 0.5e8);
    }

    function testFPow() public {
        assertEq(FixedPointMath.fpow(FixedPointMath.RAY, 2e27, 2), 4e27);
        assertEq(FixedPointMath.fpow(FixedPointMath.WAD, 2e18, 2), 4e18);
        assertEq(FixedPointMath.fpow(FixedPointMath.YAD, 2e8, 2), 4e8);
    }

    function testSqrt(uint256 x) public {
        uint256 root = FixedPointMath.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function proveMin(uint256 x, uint256 y) public {
        if (x <= y) {
            assertEq(FixedPointMath.min(x, y), x);
        } else {
            assertEq(FixedPointMath.min(x, y), y);
        }
    }

    function proveMax(uint256 x, uint256 y) public {
        if (x >= y) {
            assertEq(FixedPointMath.max(x, y), x);
        } else {
            assertEq(FixedPointMath.max(x, y), y);
        }
    }

    function proveIMin(int256 x, int256 y) public {
        if (x <= y) {
            assertEq(FixedPointMath.imin(x, y), x);
        } else {
            assertEq(FixedPointMath.imin(x, y), y);
        }
    }

    function proveIMax(int256 x, int256 y) public {
        if (x >= y) {
            assertEq(FixedPointMath.imax(x, y), x);
        } else {
            assertEq(FixedPointMath.imax(x, y), y);
        }
    }
}
