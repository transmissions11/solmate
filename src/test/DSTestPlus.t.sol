// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

contract DSTestPlusTest is DSTestPlus {
    function testBound() public {
        assertEq(bound(5, 0, 4), 0);
        assertEq(bound(0, 69, 69), 69);
        assertEq(bound(0, 68, 69), 68);
        assertEq(bound(10, 150, 190), 174);
        assertEq(bound(300, 2800, 3200), 3107);
        assertEq(bound(9999, 1337, 6666), 4669);
    }

    function testFailBoundMinBiggerThanMax() public {
        bound(5, 100, 10);
    }

    function testBound(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        if (min > max) (min, max) = (max, min);

        uint256 bounded = bound(num, min, max);

        assertGe(bounded, min);
        assertLe(bounded, max);
    }

    function testFailBoundMinBiggerThanMax(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        if (max == min) {
            unchecked {
                min++; // Overflow is handled below.
            }
        }

        if (max > min) (min, max) = (max, min);

        bound(num, min, max);
    }
}
