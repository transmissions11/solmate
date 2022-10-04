// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {PackedStringLib} from "../utils/PackedStringLib.sol";

contract PackedStringLibTest is DSTestPlus {
    function testPackString(string calldata data, bytes calldata brutalizeWith)
        external
        packableString(data)
        brutalizeMemory(brutalizeWith)
    {
        uint256 length = bytes(data).length;

        bytes32 packedString = PackedStringLib.packString(data);

        if (length == 0) {
            assertEq(packedString, bytes32(0), "Packed string not null with zero length");
        } else {
            // First byte is length
            assertEq(uint256(packedString) >> 248, length, "First byte does not match string length");
            // Last 31 bytes are body
            uint256 originalBody;
            assembly {
                originalBody := calldataload(data.offset)
            }
            assertEq(uint256(packedString) << 8, originalBody, "Last 31 bytes do not match string body");
        }
    }

    function testPackString(bytes calldata brutalizeWith) external brutalizeMemory(brutalizeWith) {
        assertEq(PackedStringLib.packString(""), bytes32(0));
        assertEq(PackedStringLib.packString(string(bytes(hex"ff"))), bytes32(uint256(0x01ff) << 240));
    }

    function testPackStringTooLong(string calldata data, bytes calldata brutalizeWith)
        external
        brutalizeMemory(brutalizeWith)
    {
        hevm.assume(bytes(data).length > 31);
        hevm.expectRevert(PackedStringLib.UnpackableString.selector);
        PackedStringLib.packString(data);
    }

    function testPackStringTooLong() external {
        bytes memory data = new bytes(32);
        hevm.expectRevert(PackedStringLib.UnpackableString.selector);
        PackedStringLib.packString(string(data));
    }

    function testUnpackStringAlwaysAllocatesTwoWords(bytes calldata brutalizeWith)
        external
        brutalizeMemory(brutalizeWith)
    {
        uint256 freeMemPtr;
        assembly {
            freeMemPtr := mload(0x40)
        }
        string memory output = PackedStringLib.unpackString(bytes32(0));
        uint256 growth;
        assembly {
            growth := sub(mload(0x40), freeMemPtr)
        }
        assertEq(growth, 0x40);
        assertEq(bytes(output).length, 0);
    }

    function testUnpackStringCanCorruptMemory(bytes calldata brutalizeWith) external brutalizeMemory(brutalizeWith) {
        // Create a badly encoded packed string advertising a length of 64 bytes
        bytes32 invalidPackedString = bytes32(uint256(0x40) << 248);
        // Unpack invalid string
        string memory output = PackedStringLib.unpackString(invalidPackedString);
        // Allocate new dynamic variable - length will overlap second word of string body
        bytes memory d = new bytes(32);
        // Addresses compiler warnings about unused variables
        assertEq(d.length * 2, bytes(output).length);
        assertEq(keccak256(bytes(output)), keccak256(abi.encodePacked(uint256(0), uint256(32))));
    }

    function testPackUnpackString(string calldata data, bytes calldata brutalizeWith)
        external
        packableString(data)
        brutalizeMemory(brutalizeWith)
    {
        assertEqIncludingPadding(PackedStringLib.unpackString(PackedStringLib.packString(data)), data);
    }

    function testPackUnpackString(bytes calldata brutalizeWith) external brutalizeMemory(brutalizeWith) {
        assertEqIncludingPadding(PackedStringLib.unpackString(bytes32(0)), string(""));
    }

    function testReturnUnpackedString(string calldata data, bytes calldata brutalizeWith)
        external
        packableString(data)
    {
        assertEqIncludingPadding(this.returnUnpackedString(PackedStringLib.packString(data), brutalizeWith), data);
    }

    function testReturnUnpackedString(bytes calldata brutalizeWith) external {
        assertEqIncludingPadding(
            this.returnUnpackedString(PackedStringLib.packString("Hello world"), brutalizeWith),
            "Hello world"
        );
    }

    /**
     * @dev Differential fuzzing for storage and retrieval of:
     * - Standard string storage, returned in returndata
     * - Packed string, unpacked with returnUnpackedString and returned in returndata
     * - Packed string, unpacked with unpackString and returned in returndata
     * - Packed string, unpacked with unpackString in same execution context
     */
    function testDifferentiallyFuzzStoreRead(string memory stringyFuzzBall, bytes calldata brutalizeWith)
        public
        brutalizeMemory(brutalizeWith)
    {
        hevm.assume(bytes(stringyFuzzBall).length < 32);
        this.setFuzzyStrings(stringyFuzzBall);
        string memory fuzzy0 = PackedStringLib.unpackString(_fuzzyStringPacked);
        string memory fuzzy1 = this.fuzzyString1(brutalizeWith);
        string memory fuzzy2 = this.fuzzyString2(brutalizeWith);
        string memory fuzzy3 = this.fuzzyString3(brutalizeWith);

        assertEqIncludingPadding(stringyFuzzBall, fuzzy0);
        assertEqIncludingPadding(fuzzy0, fuzzy1);
        assertEqIncludingPadding(fuzzy1, fuzzy2);
        assertEqIncludingPadding(fuzzy2, fuzzy3);
    }

    /// @dev Assert that the two strings are identical, including their trailing zeros
    function assertEqIncludingPadding(string memory a, string memory b) internal {
        bytes32 hashA;
        bytes32 hashB;
        assembly {
            let lenA := mload(a)
            let lenB := mload(b)

            hashA := keccak256(add(a, 32), and(add(lenA, 31), not(31)))
            hashB := keccak256(add(b, 32), and(add(lenB, 31), not(31)))
        }
        assertEq(hashA, hashB);
    }

    // Typical string storage
    string internal _fuzzyStringStandard;
    // Packed string storage
    bytes32 internal _fuzzyStringPacked;

    function returnUnpackedString(bytes32 packedString, bytes calldata brutalizeWith)
        external
        view
        brutalizeMemory(brutalizeWith)
        returns (string memory)
    {
        PackedStringLib.returnUnpackedString(packedString);
    }

    // Restrict test to allowed string sizes - test success cases
    modifier packableString(string calldata data) {
        hevm.assume(bytes(data).length < 32);
        _;
    }

    function fuzzyString1(bytes calldata brutalizeWith)
        external
        view
        brutalizeMemory(brutalizeWith)
        returns (string memory)
    {
        return _fuzzyStringStandard;
    }

    function fuzzyString2(bytes calldata brutalizeWith)
        external
        view
        brutalizeMemory(brutalizeWith)
        returns (string memory)
    {
        PackedStringLib.returnUnpackedString(_fuzzyStringPacked);
    }

    function fuzzyString3(bytes calldata brutalizeWith)
        external
        view
        brutalizeMemory(brutalizeWith)
        returns (string memory)
    {
        return PackedStringLib.unpackString(_fuzzyStringPacked);
    }

    function setFuzzyStrings(string memory stringyFuzzBall) external {
        _fuzzyStringStandard = stringyFuzzBall;
        _fuzzyStringPacked = PackedStringLib.packString(stringyFuzzBall);
    }
}
