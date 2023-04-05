// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Bytes32AddressLib} from "./Bytes32AddressLib.sol";

/// @notice Library for computing contract addresses from their deployer and nonce.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibRLP.sol)
library LibRLP {
    using Bytes32AddressLib for bytes32;

    // prettier-ignore
    function computeAddress(address deployer, uint256 nonce) internal pure returns (address) {
        // The theoretical allowed limit, based on EIP-2681, for an account nonce is 2**64-2: https://eips.ethereum.org/EIPS/eip-2681.
        // However, we assume nobody can have a nonce large enough to require more than 4 bytes.
        // Thus, no specific check is built-in to save deployment costs.

        // The integer zero is treated as an empty byte string, and as a result it only has a length prefix, 0x80, computed via 0x80 + 0.
        if (nonce == 0x00)             return keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x80))).fromLast20Bytes();
        
        // A one-byte integer in the [0x00, 0x7f] range uses its own value as a length prefix, there is no additional "0x80 + length" prefix that precedes it.
        if (nonce <= 0x7f)             return keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, uint8(nonce))).fromLast20Bytes();

        // In the case of nonce > 0x7f and nonce <= type(uint8).max, we have the following
        // encoding scheme (the same calculation can be carried over for higher nonce bytes):
        // 0xda = 0xc0 (short RLP prefix) + 0x1a (= the bytes length of: 0x94 + address + 0x84 + nonce, in hex),
        // 0x94 = 0x80 + 0x14 (= the bytes length of an address, 20 bytes, in hex),
        // 0x84 = 0x80 + 0x04 (= the bytes length of the nonce, 4 bytes, in hex).
        if (nonce <= type(uint8).max)  return keccak256(abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployer, bytes1(0x81), uint8(nonce))).fromLast20Bytes();
        if (nonce <= type(uint16).max) return keccak256(abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployer, bytes1(0x82), uint16(nonce))).fromLast20Bytes();
        if (nonce <= type(uint24).max) return keccak256(abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployer, bytes1(0x83), uint24(nonce))).fromLast20Bytes();

        // Case for nonce > uint24 and nonce <= type(uint32).max.
        return keccak256(abi.encodePacked(bytes1(0xda), bytes1(0x94), deployer, bytes1(0x84), uint32(nonce))).fromLast20Bytes();
    }
}
