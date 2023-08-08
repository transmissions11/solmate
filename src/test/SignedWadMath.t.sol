// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {wadMul, wadDiv} from "../utils/SignedWadMath.sol";

contract SignedWadMathTest is DSTestPlus {
    function testWadMul(
        uint256 x,
        uint256 y,
        bool negX,
        bool negY
    ) public {
        x = bound(x, 0, 99999999999999e18);
        y = bound(x, 0, 99999999999999e18);

        int256 xPrime = negX ? -int256(x) : int256(x);
        int256 yPrime = negY ? -int256(y) : int256(y);

        assertEq(wadMul(xPrime, yPrime), (xPrime * yPrime) / 1e18);
    }

    function testFailWadMulEdgeCase() public pure {
        int256 x = -1;
        int256 y = type(int256).min;

        wadMul(x, y);
    }

    function testFailWadMulEdgeCase2() public pure {
        int256 x = type(int256).min;
        int256 y = -1;

        wadMul(x, y);
    }

    function testFailWadMulOverflow(int256 x, int256 y) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        wadMul(x, y);
    }

    function testWadDiv(
        uint256 x,
        uint256 y,
        bool negX,
        bool negY
    ) public {
        x = bound(x, 0, 99999999e18);
        y = bound(x, 1, 99999999e18);

        int256 xPrime = negX ? -int256(x) : int256(x);
        int256 yPrime = negY ? -int256(y) : int256(y);

        assertEq(wadDiv(xPrime, yPrime), (xPrime * 1e18) / yPrime);
    }

    function testFailWadDivOverflow(int256 x, int256 y) public pure {
        // Ignore cases where x * WAD does not overflow or y is 0.
        unchecked {
            if (y == 0 || (x * 1e18) / 1e18 == x) revert();
        }

        wadDiv(x, y);
    }

    function testFailWadDivZeroDenominator(int256 x) public pure {
        wadDiv(x, 0);
    }
}
