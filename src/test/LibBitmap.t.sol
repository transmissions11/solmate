// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {LibBitmap} from "../src/utils/LibBitmap.sol";

contract LibBitmapTest is Test {
    using LibBitmap for LibBitmap.Bitmap;

    error AlreadyClaimed();

    LibBitmap.Bitmap bitmap;

    function get(uint256 index) public view returns (bool result) {
        result = bitmap.get(index);
    }

    function set(uint256 index) public {
        bitmap.set(index);
    }

    function unset(uint256 index) public {
        bitmap.unset(index);
    }

    function toggle(uint256 index) public {
        bitmap.toggle(index);
    }

    function setTo(uint256 index, bool shouldSet) public {
        bitmap.setTo(index, shouldSet);
    }

    function claimWithGetSet(uint256 index) public {
        if (bitmap.get(index)) {
            revert AlreadyClaimed();
        }
        bitmap.set(index);
    }

    function claimWithToggle(uint256 index) public {
        if (bitmap.toggle(index) == false) {
            revert AlreadyClaimed();
        }
    }

    function testBitmapGet() public {
        testBitmapGet(111111);
    }

    function testBitmapGet(uint256 index) public {
        assertFalse(get(index));
    }

    function testBitmapSetAndGet(uint256 index) public {
        set(index);
        bool result = get(index);
        bool resultIsOne;
        assembly {
            resultIsOne := eq(result, 1)
        }
        assertTrue(result);
        assertTrue(resultIsOne);
    }

    function testBitmapSet() public {
        testBitmapSet(222222);
    }

    function testBitmapSet(uint256 index) public {
        set(index);
        assertTrue(get(index));
    }

    function testBitmapUnset() public {
        testBitmapSet(333333);
    }

    function testBitmapUnset(uint256 index) public {
        set(index);
        assertTrue(get(index));
        unset(index);
        assertFalse(get(index));
    }

    function testBitmapSetTo() public {
        testBitmapSetTo(555555, true, 0);
        testBitmapSetTo(555555, false, 0);
    }

    function testBitmapSetTo(
        uint256 index,
        bool shouldSet,
        uint256 randomness
    ) public {
        bool shouldSetBrutalized;
        assembly {
            if shouldSet {
                shouldSetBrutalized := or(iszero(randomness), randomness)
            }
        }
        setTo(index, shouldSetBrutalized);
        assertEq(get(index), shouldSet);
    }

    function testBitmapSetTo(uint256 index, uint256 randomness) public {
        randomness = uint256(keccak256(abi.encode(randomness)));
        unchecked {
            for (uint256 i; i < 5; ++i) {
                bool shouldSet;
                assembly {
                    shouldSet := and(shr(i, randomness), 1)
                }
                testBitmapSetTo(index, shouldSet, randomness);
            }
        }
    }

    function testBitmapToggle() public {
        testBitmapToggle(777777, true);
        testBitmapToggle(777777, false);
    }

    function testBitmapToggle(uint256 index, bool initialValue) public {
        setTo(index, initialValue);
        assertEq(get(index), initialValue);
        toggle(index);
        assertEq(get(index), !initialValue);
    }

    function testBitmapClaimWithGetSet() public {
        uint256 index = 888888;
        this.claimWithGetSet(index);
        vm.expectRevert(AlreadyClaimed.selector);
        this.claimWithGetSet(index);
    }

    function testBitmapClaimWithToggle() public {
        uint256 index = 999999;
        this.claimWithToggle(index);
        vm.expectRevert(AlreadyClaimed.selector);
        this.claimWithToggle(index);
    }
}
