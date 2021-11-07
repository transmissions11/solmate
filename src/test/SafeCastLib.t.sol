// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {SafeCastLib} from "../utils/SafeCastLib.sol";

contract SafeCastLibTest is DSTestPlus {
    function testSafeCastTo224() public {
        assertEq(SafeCastLib.safeCastTo224(2.5e45), 2.5e45);
        assertEq(SafeCastLib.safeCastTo224(2.5e27), 2.5e27);
    }

    function testSafeCastTo128() public {
        assertEq(SafeCastLib.safeCastTo128(2.5e27), 2.5e27);
        assertEq(SafeCastLib.safeCastTo128(2.5e18), 2.5e18);
    }

    function testSafeCastTo64() public {
        assertEq(SafeCastLib.safeCastTo64(2.5e18), 2.5e18);
        assertEq(SafeCastLib.safeCastTo64(2.5e17), 2.5e17);
    }

    function testFailSafeCastTo224() public pure {
        SafeCastLib.safeCastTo224(type(uint224).max + 1);
    }

    function testFailSafeCastTo128() public pure {
        SafeCastLib.safeCastTo128(type(uint128).max + 1);
    }

    function testFailSafeCastTo64() public pure {
        SafeCastLib.safeCastTo64(type(uint64).max + 1);
    }

    function testSafeCastTo224(uint256 x) public {
        x %= type(uint224).max;

        assertEq(SafeCastLib.safeCastTo224(x), x);
    }

    function testSafeCastTo128(uint256 x) public {
        x %= type(uint128).max;

        assertEq(SafeCastLib.safeCastTo128(x), x);
    }

    function testSafeCastTo64(uint256 x) public {
        x %= type(uint64).max;

        assertEq(SafeCastLib.safeCastTo64(x), x);
    }

    function testFailSafeCastTo224(uint256 x) public pure {
        if (type(uint224).max > x) revert();

        SafeCastLib.safeCastTo224(x);
    }

    function testFailSafeCastTo128(uint256 x) public pure {
        if (type(uint128).max > x) revert();

        SafeCastLib.safeCastTo128(x);
    }

    function testFailSafeCastTo64(uint256 x) public pure {
        if (type(uint64).max > x) revert();

        SafeCastLib.safeCastTo64(x);
    }
}
