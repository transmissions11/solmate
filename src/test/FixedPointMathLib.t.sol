// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTestPlus {
    function testFMul() public {
        assertEq(FixedPointMathLib.fmul(2.5e27, 0.5e27, FixedPointMathLib.RAY), 1.25e27);
        assertEq(FixedPointMathLib.fmul(2.5e18, 0.5e18, FixedPointMathLib.WAD), 1.25e18);
        assertEq(FixedPointMathLib.fmul(2.5e8, 0.5e8, FixedPointMathLib.YAD), 1.25e8);
    }

    function testFMulEdgeCases() public {
        // TODO: I'm okay with fmul reverting when baseUnit == 0 if it leads to a cheaper fmul.
        // Will remove this line and uncomment the tests below if that's what we go with.
        assertEq(FixedPointMathLib.fmul(1e18, 1e18, 0), 0);

        assertEq(FixedPointMathLib.fmul(0, 1e18, FixedPointMathLib.WAD), 0);
        assertEq(FixedPointMathLib.fmul(1e18, 0, FixedPointMathLib.WAD), 0);
        assertEq(FixedPointMathLib.fmul(0, 0, FixedPointMathLib.WAD), 0);
    }

    // TODO: Add these back as self-documentation if we decide to go with an implementation that reverts when baseUnit == 0.

    // function testFailFMulZeroB() public pure {
    //     FixedPointMathLib.fmul(1e18, 1e18, 0);
    // }

    // function testFailFMulZeroXYB() public pure {
    //     FixedPointMathLib.fmul(0, 0, 0);
    // }

    function testFDiv() public {
        assertEq(FixedPointMathLib.fdiv(1e27, 2e27, FixedPointMathLib.RAY), 0.5e27);
        assertEq(FixedPointMathLib.fdiv(1e18, 2e18, FixedPointMathLib.WAD), 0.5e18);
        assertEq(FixedPointMathLib.fdiv(1e8, 2e8, FixedPointMathLib.YAD), 0.5e8);
    }

    function testFDivEdgeCases() public {
        assertEq(FixedPointMathLib.fdiv(1e8, 1e18, 0), 0);
        assertEq(FixedPointMathLib.fdiv(0, 1e18, FixedPointMathLib.WAD), 0);
    }

    function testFailFDivZeroY() public pure {
        FixedPointMathLib.fdiv(1e18, 0, FixedPointMathLib.WAD);
    }

    function testFailFDivZeroXY() public pure {
        FixedPointMathLib.fdiv(0, 0, FixedPointMathLib.WAD);
    }

    function testFailFDivXYB() public pure {
        FixedPointMathLib.fdiv(0, 0, 0);
    }

    function testFPow() public {
        assertEq(FixedPointMathLib.fpow(2e27, 2, FixedPointMathLib.RAY), 4e27);
        assertEq(FixedPointMathLib.fpow(2e18, 2, FixedPointMathLib.WAD), 4e18);
        assertEq(FixedPointMathLib.fpow(2e8, 2, FixedPointMathLib.YAD), 4e8);
    }

    function testSqrt() public {
        assertEq(FixedPointMathLib.sqrt(2704), 52);
        assertEq(FixedPointMathLib.sqrt(110889), 333);
        assertEq(FixedPointMathLib.sqrt(32239684), 5678);
    }

    function testMin() public {
        assertEq(FixedPointMathLib.min(4, 100), 4);
        assertEq(FixedPointMathLib.min(500, 400), 400);
        assertEq(FixedPointMathLib.min(10000, 10001), 10000);
        assertEq(FixedPointMathLib.min(1e18, 0.1e18), 0.1e18);
    }

    function testMax() public {
        assertEq(FixedPointMathLib.max(4, 100), 100);
        assertEq(FixedPointMathLib.max(500, 400), 500);
        assertEq(FixedPointMathLib.max(10000, 10001), 10001);
        assertEq(FixedPointMathLib.max(1e18, 0.1e18), 1e18);
    }

    // TODO: can these all be symbolic?

    function testFuzzFMul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }

        assertEq(FixedPointMathLib.fmul(x, y, baseUnit), baseUnit == 0 ? 0 : (x * y) / baseUnit);
    }

    function testFuzzFDiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public {
        // Ignore cases where x * baseUnit overflows.
        unchecked {
            if (x != 0 && (x * baseUnit) / x != baseUnit) return;
        }

        // Ignore cases where y is zero because it will cause a revert.
        if (y == 0) {
            return;
        }

        assertEq(FixedPointMathLib.fdiv(x, y, baseUnit), (x * baseUnit) / y);
    }

    function testFailFuzzFDivYZero(uint256 x, uint256 baseUnit) public pure {
        FixedPointMathLib.fdiv(x, 0, baseUnit);
    }

    function testFuzzSqrt(uint256 x) public {
        uint256 root = FixedPointMathLib.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function testFuzzMin(uint256 x, uint256 y) public {
        if (x < y) {
            assertEq(FixedPointMathLib.min(x, y), x);
        } else {
            assertEq(FixedPointMathLib.min(x, y), y);
        }
    }

    function testFuzzMax(uint256 x, uint256 y) public {
        if (x > y) {
            assertEq(FixedPointMathLib.max(x, y), x);
        } else {
            assertEq(FixedPointMathLib.max(x, y), y);
        }
    }
}
