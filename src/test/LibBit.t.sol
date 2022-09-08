// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {LibBit} from "../src/utils/LibBit.sol";

contract LibBitTest is Test {
    function testFuzzMSB() public {
        for (uint256 i = 1; i < 255; i++) {
            assertEq(LibBit.msb((1 << i) - 1), i - 1);
            assertEq(LibBit.msb((1 << i)), i);
            assertEq(LibBit.msb((1 << i) + 1), i);
        }
        assertEq(LibBit.msb(0), 256);
    }

    function testMSB() public {
        assertEq(LibBit.msb(0xff << 3), 10);
    }

    function testFuzzLSB() public {
        uint256 brutalizer = uint256(keccak256(abi.encode(address(this), block.timestamp)));
        for (uint256 i = 0; i < 256; i++) {
            assertEq(LibBit.lsb(1 << i), i);
            assertEq(LibBit.lsb(type(uint256).max << i), i);
            assertEq(LibBit.lsb((brutalizer | 1) << i), i);
        }
        assertEq(LibBit.lsb(0), 256);
    }

    function testLSB() public {
        assertEq(LibBit.lsb(0xff << 3), 3);
    }

    function testFuzzPopCount(uint256 x) public {
        uint256 c;
        unchecked {
            for (uint256 t = x; t != 0; c++) {
                t &= t - 1;
            }
        }
        assertEq(LibBit.popCount(x), c);
    }

    function testPopCount() public {
        assertEq(LibBit.popCount((1 << 255) | 1), 2);
    }
}
