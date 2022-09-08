// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {LibString} from "../utils/LibString.sol";

contract LibStringTest is DSTestPlus {
    function testToString() public {
        assertEq(LibString.toString(0), "0");
        assertEq(LibString.toString(1), "1");
        assertEq(LibString.toString(17), "17");
        assertEq(LibString.toString(99999999), "99999999");
        assertEq(LibString.toString(99999999999), "99999999999");
        assertEq(LibString.toString(2342343923423), "2342343923423");
        assertEq(LibString.toString(98765685434567), "98765685434567");
    }

    function testDifferentiallyFuzzToString(uint256 value, bytes calldata brutalizeWith)
        public
        brutalizeMemory(brutalizeWith)
    {
        string memory libString = LibString.toString(value);
        string memory oz = toStringOZ(value);

        assertEq(bytes(libString).length, bytes(oz).length);
        assertEq(libString, oz);
    }

    function testToStringOverwrite() public {
        string memory str = LibString.toString(1);

        bytes32 data;
        bytes32 expected;

        assembly {
            // Imagine a high level allocation writing something to the current free memory.
            // Should have sufficient higher order bits for this to be visible
            mstore(mload(0x40), not(0))
            // Correctly allocate 32 more bytes, to avoid more interference
            mstore(0x40, add(mload(0x40), 32))
            data := mload(add(str, 32))

            // the expected value should be the uft-8 encoding of 1 (49),
            // followed by clean bits. We achieve this by taking the value and
            // shifting left to the end of the 32 byte word
            expected := shl(248, 49)
        }

        assertEq(data, expected);
    }

    function testToStringDirty() public {
        uint256 freememptr;
        // Make the next 4 bytes of the free memory dirty
        assembly {
            let dirty := not(0)
            freememptr := mload(0x40)
            mstore(freememptr, dirty)
            mstore(add(freememptr, 32), dirty)
            mstore(add(freememptr, 64), dirty)
            mstore(add(freememptr, 96), dirty)
            mstore(add(freememptr, 128), dirty)
        }
        string memory str = LibString.toString(1);
        uint256 len;
        bytes32 data;
        bytes32 expected;
        assembly {
            freememptr := str
            len := mload(str)
            data := mload(add(str, 32))
            // the expected value should be the uft-8 encoding of 1 (49),
            // followed by clean bits. We achieve this by taking the value and
            // shifting left to the end of the 32 byte word
            expected := shl(248, 49)
        }
        emit log_named_uint("str: ", freememptr);
        emit log_named_uint("len: ", len);
        emit log_named_bytes32("data: ", data);
        assembly {
            freememptr := mload(0x40)
        }
        emit log_named_uint("memptr: ", freememptr);

        assertEq(data, expected);
    }
}

function toStringOZ(uint256 value) pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}
