// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author SolDAO (https://github.com/Sol-DAO/solmate/blob/main/src/utils/MerkleProofLib.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)
library MerkleProofLib {
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        assembly {
            if proof.length {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                let end := add(proof.offset, shl(5, proof.length))
                // Initialize `offset` to the offset of `proof` in the calldata.
                let offset := proof.offset
                // Iterate over proof elements to compute root hash.
                // prettier-ignore
                for {} 1 {} {
                    // Slot of `leaf` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(leaf, calldataload(offset)))
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(scratch, leaf)
                    mstore(xor(scratch, 0x20), calldataload(offset))
                    // Reuse `leaf` to store the hash to reduce stack operations.
                    leaf := keccak256(0x00, 0x40)
                    offset := add(offset, 0x20)
                    // prettier-ignore
                    if iszero(lt(offset, end)) { break }
                }
            }
            isValid := eq(leaf, root)
        }
    }

    function verifyMultiProof(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leafs,
        bool[] calldata flags
    ) internal pure returns (bool isValid) {
        // Rebuilds the root by consuming and producing values on a queue.
        // The queue starts with the `leafs` array, and goes into a `hashes` array.
        // After the process, the last element on the queue is verified
        // to be equal to the `root`.
        //
        // The `flags` array denotes whether the sibling
        // should be popped from the queue (`flag == true`), or
        // should be popped from the `proof` (`flag == false`).
        assembly {
            // If the number of flags is correct.
            // prettier-ignore
            for {} eq(add(leafs.length, proof.length), add(flags.length, 1)) {} {
                // Left shift by 5 is equivalent to multiplying by 0x20.
                // Compute the end calldata offset of `leafs`.
                let leafsEnd := add(leafs.offset, shl(5, leafs.length))
                // These are the calldata offsets.
                let leafsOffset := leafs.offset
                let flagsOffset := flags.offset
                let proofOffset := proof.offset

                // We can use the free memory space for the queue.
                // We don't need to allocate, since the queue is temporary.
                let hashesFront := mload(0x40)
                let hashesBack := hashesFront
                // This is the end of the memory for the queue.
                let end := add(hashesBack, shl(5, flags.length))

                // For the case where `proof.length + leafs.length == 1`.
                if iszero(flags.length) {
                    // If `proof.length` is zero, `leafs.length` is 1.
                    if iszero(proof.length) {
                        isValid := eq(calldataload(leafsOffset), root)
                        break
                    }
                    // If `leafs.length` is zero, `proof.length` is 1.
                    if iszero(leafs.length) {
                        isValid := eq(calldataload(proofOffset), root)
                        break
                    }
                }

                // prettier-ignore
                for {} 1 {} {
                    let a := 0
                    // Pops a value from the queue into `a`.
                    switch lt(leafsOffset, leafsEnd)
                    case 0 {
                        // Pop from `hashes` if there are no more leafs.
                        a := mload(hashesFront)
                        hashesFront := add(hashesFront, 0x20)
                    }
                    default {
                        // Otherwise, pop from `leafs`.
                        a := calldataload(leafsOffset)
                        leafsOffset := add(leafsOffset, 0x20)
                    }

                    let b := 0
                    // If the flag is false, load the next proof,
                    // else, pops from the queue.
                    switch calldataload(flagsOffset)
                    case 0 {
                        // Loads the next proof.
                        b := calldataload(proofOffset)
                        proofOffset := add(proofOffset, 0x20)
                    }
                    default {
                        // Pops a value from the queue into `a`.
                        switch lt(leafsOffset, leafsEnd)
                        case 0 {
                            // Pop from `hashes` if there are no more leafs.
                            b := mload(hashesFront)
                            hashesFront := add(hashesFront, 0x20)
                        }
                        default {
                            // Otherwise, pop from `leafs`.
                            b := calldataload(leafsOffset)
                            leafsOffset := add(leafsOffset, 0x20)
                        }
                    }
                    // Advance to the next flag offset.
                    flagsOffset := add(flagsOffset, 0x20)

                    // Slot of `a` in scratch space.
                    // If the condition is true: 0x20, otherwise: 0x00.
                    let scratch := shl(5, gt(a, b))
                    // Hash the scratch space and push the result onto the queue.
                    mstore(scratch, a)
                    mstore(xor(scratch, 0x20), b)
                    mstore(hashesBack, keccak256(0x00, 0x40))
                    hashesBack := add(hashesBack, 0x20)
                    // prettier-ignore
                    if iszero(lt(hashesBack, end)) { break }
                }
                // Checks if the last value in the queue is same as the root.
                isValid := eq(mload(sub(hashesBack, 0x20)), root)
                break
            }
        }
    }
}
