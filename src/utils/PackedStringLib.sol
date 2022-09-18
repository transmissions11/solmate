// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Efficient library for encoding/decoding strings shorter than 32 bytes as one word.
/// @notice Solidity has built-in functionality for storing strings shorter than 32 bytes in
/// a single word, but it must determine at runtime whether to treat each string as one word
/// or several. This introduces a significant amount of bytecode and runtime complexity to
/// any contract storing strings.
/// @notice When it is known in advance that a string will never be longer than 31 bytes,
/// telling the compiler to always treat strings as such can greatly reduce extraneous runtime
/// code that would have never been executed.
/// @notice https://docs.soliditylang.org/en/v0.8.17/types.html#bytes-and-string-as-arrays
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/PackedStringLib.sol)
library PackedStringLib {
    error UnpackableString();

    /// @dev Pack a 0-31 byte string into a bytes32.
    /// @dev Will revert if string exceeds 31 bytes.
    function packString(string memory unpackedString) internal pure returns (bytes32 packedString) {
        uint256 length = bytes(unpackedString).length;
        // Verify string length and body will fit into one word
        if (length > 31) {
            revert UnpackableString();
        }
        assembly {
            // -------------------------------------------------------------------------//
            // Layout in memory of input string (less than 32 bytes)                    //
            // Note that "position" is relative to the pointer, not absolute            //
            // -------------------------------------------------------------------------//
            // Bytes   | Value             | Description                                //
            // -------------------------------------------------------------------------//
            // 0:31     | 0                 | Empty left-padding for string length      //
            //          |                   | Not included in output                    //
            // 31:32    | length            | Single-byte length between 0 and 31       //
            // 32:63    | body / unknown    | Right-padded string body if length > 0    //
            //          |                   | Unknown if length is zero                 //
            // 63:64    | 0 / unknown       | Empty right-padding byte for string if    //
            //          |                   | length > 0; otherwise, unknown data       //
            //          |                   | This byte is never included in the output //
            // -------------------------------------------------------------------------//

            // Read one word starting at the last byte of the length, so that the first
            // byte of the packed string will be its length (left-padded) and the
            // following 31 bytes will contain the string's body (right-padded).
            packedString := mul(
                mload(add(unpackedString, 31)),
                // If length is zero, the word after length will not be allocated for
                // the body and may contain dirty bits. We multiply the packed value by
                // length > 0 to ensure the body is null if the length is zero.
                iszero(iszero(length))
            )
        }
    }

    /// @dev Return the unpacked form of `packedString`.
    /// @notice Ends contract execution and returns the string - should only
    /// be used in an external function with a string return type.
    /// @notice Does not check `packedString` has valid encoding, assumes it was created
    /// by `packString`.
    function returnUnpackedString(bytes32 packedString) internal pure {
        assembly {
            // ---------------------------------------------------------------------//
            // Unpacked string layout in memory & returndata                        //
            // ---------------------------------------------------------------------//
            // Position | Value            | Description                            //
            // ---------------------------------------------------------------------//
            // 0:32     | 32               | Offset to string length                //
            // 32:63    | 0                | Empty left-padding for string length   //
            // 63:64    | String length    | Single-byte length of string           //
            // 64:95    | String body      | 0-31 byte right-padded string body     //
            // 95:96    | 0                | Empty right-padding for string body    //
            // ---------------------------------------------------------------------//

            // Write the offset to the string in the first word of scratch space.
            mstore(0x00, 0x20)

            // Note: We could shift the returndata right 32 bytes to avoid regions
            // that Solidity's normal memory management would contaminate; starting at
            // zero and manually clearing the padding bits protects against developer
            // error where the developer is manipulating the zero slot and using very
            // large numbers in the free memory pointer slot.

            // Clear the 0x20 and 0x40 slots to ensure dirty bits do not contaminate
            // the left-padding for length or right-padding for body.
            mstore(0x20, 0x00)
            mstore(0x40, 0x00)

            // Write the packed string to memory starting at the last byte of the
            // length buffer, writing the length byte to the end of the first word
            // and the 0-31 byte body at the start of the second word.
            mstore(0x3f, packedString)

            // Return (offset, length, body)
            return(0x00, 0x60)
        }
    }

    /// @dev Memory-safe string unpacking - updates the free memory pointer to
    /// allocate space for the string. Useful for strings which are used within
    /// the contract and not simply returned in metadata queries.
    /// @notice Does not check `packedString` has valid encoding, assumes it was created
    /// by `packString`.
    /// Note that supplying an input not generated by this library can result in severe memory
    /// corruption. The returned string can have an apparent length of up to 255 bytes and
    /// overflow into adjacent memory regions if it is not encoded correctly.
    function unpackString(bytes32 packedString) internal pure returns (string memory unpackedString) {
        assembly {
            // Set pointer for `unpackedString` to free memory pointer.
            unpackedString := mload(0x40)
            // Clear full buffer - it may contain dirty (unallocated) data.
            // Normally this would not matter for the trailing zeroes of the body,
            // but developers may assume that strings are padded to full words so
            // we maintain that practice here.
            mstore(unpackedString, 0)
            mstore(add(unpackedString, 0x20), 0)
            // Increase free memory pointer by 64 bytes to allocate space for
            // the string's length and body - prevents Solidity's memory
            // management from overwriting it.
            mstore(0x40, add(unpackedString, 0x40))
            // Write the packed string to memory starting at the last byte of the
            // length buffer. This places the single-byte length at the end of the
            // length word and the 0-31 byte body at the start of the body word.
            mstore(add(unpackedString, 0x1f), packedString)
        }
    }
}
