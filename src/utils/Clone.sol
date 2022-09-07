// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Class with helper read functions for clone with immutable args.
/// @author SolDAO (https://github.com/Sol-DAO/solmate/blob/main/src/utils/Clone.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/Clone.sol)
abstract contract Clone {
    /// @dev Reads an immutable arg with type address.
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint256
    function _getArgUint256(uint256 argOffset) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads a uint256 array stored in the immutable args.
    function _getArgUint256Array(uint256 argOffset, uint256 length) internal pure returns (uint256[] memory arr) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            // Grab the free memory pointer.
            arr := mload(0x40)
            // Store the array length.
            mstore(arr, length)
            // Copy the array.
            calldatacopy(add(arr, 0x20), add(offset, argOffset), shl(5, length))
            // Allocate the memory
            mstore(0x40, add(add(arr, 0x20), shl(5, length)))
        }
    }

    /// @dev Reads an immutable arg with type uint64.
    function _getArgUint64(uint256 argOffset) internal pure returns (uint64 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint8.
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata.
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        assembly {
            offset := sub(calldatasize(), shr(0xf0, calldataload(sub(calldatasize(), 2))))
        }
    }
}
