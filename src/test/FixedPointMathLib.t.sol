// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTestPlus {
    function testFMul() public {
        assertEq(FixedPointMathLib.fmul(2.5e27, 0.5e27, FixedPointMathLib.RAY), 1.25e27);
        assertEq(FixedPointMathLib.fmul(2.5e18, 0.5e18, FixedPointMathLib.WAD), 1.25e18);
        assertEq(FixedPointMathLib.fmul(2.5e8, 0.5e8, FixedPointMathLib.YAD), 1.25e8);
    }

    function testFMulEdgeCases() public {
        assertEq(FixedPointMathLib.fmul(0, 1e18, FixedPointMathLib.WAD), 0);
        assertEq(FixedPointMathLib.fmul(1e18, 0, FixedPointMathLib.WAD), 0);
        assertEq(FixedPointMathLib.fmul(0, 0, FixedPointMathLib.WAD), 0);
        assertEq(FixedPointMathLib.fmul(1e18, 1e18, 0), 0);
    }

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
        assertEq(FixedPointMathLib.sqrt(0), 0);
        assertEq(FixedPointMathLib.sqrt(1), 1);
        assertEq(FixedPointMathLib.sqrt(2704), 52);
        assertEq(FixedPointMathLib.sqrt(110889), 333);
        assertEq(FixedPointMathLib.sqrt(32239684), 5678);
    }

    function testFMul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public {
        // Convert cases where x * y overflows into useful test cases.
        unchecked {
            while (x != 0 && (x * y) / x != y) {
                x /= 2;
                y /= 2;
            }
        }

        assertEq(FixedPointMathLib.fmul(x, y, baseUnit), baseUnit == 0 ? 0 : (x * y) / baseUnit);
    }

    function testFailFMulOverflow(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        FixedPointMathLib.fmul(x, y, baseUnit);
    }

    function testFDiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public {
        if (y == 0) y = 1;

        // Ignore cases where x * baseUnit overflows.
        unchecked {
            if (x != 0 && (x * baseUnit) / x != baseUnit) return;
        }

        assertEq(FixedPointMathLib.fdiv(x, y, baseUnit), (x * baseUnit) / y);
    }

    function testFailFDivOverflow(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) public pure {
        // Ignore cases where x * baseUnit does not overflow.
        unchecked {
            if ((x * baseUnit) / x == baseUnit) revert();
        }

        FixedPointMathLib.fdiv(x, y, baseUnit);
    }

    function testFailFDivYZero(uint256 x, uint256 baseUnit) public pure {
        FixedPointMathLib.fdiv(x, 0, baseUnit);
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
}
