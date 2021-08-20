// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {FixedPointMath} from "../utils/FixedPointMath.sol";

contract FixedPointMathTest is DSTestPlus {
    function testFMul() public {
        assertEq(FixedPointMath.fmul(2.5e27, 0.5e27, FixedPointMath.RAY), 1.25e27);
        assertEq(FixedPointMath.fmul(2.5e18, 0.5e18, FixedPointMath.WAD), 1.25e18);
        assertEq(FixedPointMath.fmul(2.5e8, 0.5e8, FixedPointMath.YAD), 1.25e8);
    }

    function testFDiv() public {
        assertEq(FixedPointMath.fdiv(1e27, 2e27, FixedPointMath.RAY), 0.5e27);
        assertEq(FixedPointMath.fdiv(1e18, 2e18, FixedPointMath.WAD), 0.5e18);
        assertEq(FixedPointMath.fdiv(1e8, 2e8, FixedPointMath.YAD), 0.5e8);
    }

    function testFPow() public {
        assertEq(FixedPointMath.fpow(2e27, 2, FixedPointMath.RAY), 4e27);
        assertEq(FixedPointMath.fpow(2e18, 2, FixedPointMath.WAD), 4e18);
        assertEq(FixedPointMath.fpow(2e8, 2, FixedPointMath.YAD), 4e8);
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

    function testMin(uint256 x, uint256 y) public {
        if (x <= y) {
            assertEq(FixedPointMath.min(x, y), x);
        } else {
            assertEq(FixedPointMath.min(x, y), y);
        }
    }

    function testMax(uint256 x, uint256 y) public {
        if (x >= y) {
            assertEq(FixedPointMath.max(x, y), x);
        } else {
            assertEq(FixedPointMath.max(x, y), y);
        }
    }
}
