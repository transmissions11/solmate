// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTest} from "ds-test/test.sol";

import {MathHelpers} from "../utils/MathHelpers.sol";

contract MathHelpersTest is DSTest {
    function testMin(uint256 x, uint256 y) public {
        if (x <= y) {
            assertEq(MathHelpers.min(x, y), x);
        } else {
            assertEq(MathHelpers.min(x, y), y);
        }
    }

    function testMax(uint256 x, uint256 y) public {
        if (x >= y) {
            assertEq(MathHelpers.max(x, y), x);
        } else {
            assertEq(MathHelpers.max(x, y), y);
        }
    }

    function testIMin(int256 x, int256 y) public {
        if (x <= y) {
            assertEq(MathHelpers.imin(x, y), x);
        } else {
            assertEq(MathHelpers.imin(x, y), y);
        }
    }

    function testIMax(int256 x, int256 y) public {
        if (x >= y) {
            assertEq(MathHelpers.imax(x, y), x);
        } else {
            assertEq(MathHelpers.imax(x, y), y);
        }
    }

    function testSqrt(uint256 x) public {
        uint256 root = MathHelpers.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function tesPow(uint8 _x, uint8 _n) public {
        // Avoid overflows.
        uint256 x = _x % 50;
        uint256 n = _n % 50;

        assertEq(MathHelpers.pow(x, n, 1), x**n);
    }
}
