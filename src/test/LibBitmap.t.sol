// SPDX-License-Identifier: MIT
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

    function testBitmapSetTo() public {
        testBitmapSetTo(123, true);
        testBitmapSetTo(123, false);
    }

    function testBitmapSetTo(uint256 index, bool shouldSet) public {
        mockLibBitmap.setTo(index, shouldSet);
        assertTrue(mockLibBitmap.get(index) == shouldSet);
    }
}
