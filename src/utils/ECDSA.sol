// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/MerkleProof.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library ECDSA {
    function recover(bytes32 hash, bytes calldata signature) internal pure returns (address result) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        bool isValid;
        assembly {
            // Directly load the fields from the calldata.
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 0x20))
            switch signature.length
            case 65 {
                v := byte(0, calldataload(add(signature.offset, 0x40)))
            }
            case 64 {
                // Here, `s` is actually `vs` that needs to be recovered into `v` and `s`.
                v := add(shr(255, s), 27)
                // prettier-ignore
                s := and(s, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            }
            // Ensure signature is valid and not malleable.
            isValid := and(
                // `s` in lower half order.
                // prettier-ignore
                lt(s, 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a1),
                // `v` is 27 or 28
                byte(v, 0x0101000000)
            )
        }
        if (isValid) {
            // If invalid, the result will be the zero address.
            result = ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        assembly {
            // Store into scratch space for keccak256.
            mstore(0x20, hash)
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32")
            // 0x40 - 0x04 = 0x3c
            result := keccak256(0x04, 0x3c)
        }
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        assembly {
            let ptr := add(mload(0x40), 128)

            let mid := ptr
            let sLength := mload(s)
            let end := add(mid, sLength)

            // Update the free memory pointer to allocate.
            mstore(0x40, shl(5, add(1, shr(5, end))))

            // Convert the length of the bytes to ASCII decimal representation
            // and concatenate to the signature.
            for {
                let temp := sLength
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp {
                temp := div(temp, 10)
            } {
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }

            // Move the pointer 32 bytes lower to make room for the prefix.
            let start := sub(ptr, 32)
            // Concatenate the prefix to the signature.
            mstore(start, "\x00\x00\x00\x00\x00\x00\x19Ethereum Signed Message:\n")
            start := add(start, 6)

            // Concatenate the bytes to the signature.
            for {
                let temp := add(s, 0x20)
                ptr := mid
            } lt(ptr, end) {
                ptr := add(ptr, 0x20)
            } {
                mstore(ptr, mload(temp))
                temp := add(temp, 0x20)
            }
            result := keccak256(start, sub(end, start))
        }
    }
}
