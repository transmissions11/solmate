// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MockLibBitmap} from "./utils/mocks/MockLibBitmap.sol";

contract LibBitmapTest is DSTestPlus {
    MockLibBitmap mockLibBitmap;

    function setUp() public {
        mockLibBitmap = new MockLibBitmap();
    }

    function testBitmapGet() public {
        testBitmapGet(123);
    }

    function testBitmapGet(uint256 index) public {
        assertFalse(mockLibBitmap.get(index));
    }

    function testBitmapSet() public {
        testBitmapSet(123);
    }

    function testBitmapSet(uint256 index) public {
        mockLibBitmap.set(index);
        assertTrue(mockLibBitmap.get(index));
    }

    function testBitmapUnset() public {
        testBitmapSet(123);
    }

    function testBitmapUnset(uint256 index) public {
        mockLibBitmap.set(index);
        assertTrue(mockLibBitmap.get(index));
        mockLibBitmap.unset(index);
        assertFalse(mockLibBitmap.get(index));
    }

    function testBitmapSetTo() public {
        testBitmapSetTo(123, true);
        testBitmapSetTo(123, false);
    }

    function testBitmapSetTo(uint256 index, bool shouldSet) public {
        mockLibBitmap.setTo(index, shouldSet);
        assertBoolEq(mockLibBitmap.get(index), shouldSet);
    }

    function testBitmapToggle() public {
        testBitmapToggle(123, true);
        testBitmapToggle(321, false);
    }

    function testBitmapToggle(uint256 index, bool initialValue) public {
        mockLibBitmap.setTo(index, initialValue);
        assertBoolEq(mockLibBitmap.get(index), initialValue);
        mockLibBitmap.toggle(index);
        assertBoolEq(mockLibBitmap.get(index), !initialValue);
    }
}
