// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized verification of proof of inclusion for a leaf in a Merkle tree.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/MerkleProof.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol)
library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        assembly {
            let computedHash := leaf

            // Get the memory start location of the first element in the proof array.
            let data := add(proof, 0x20)

            // Iterate over proof elements to compute root hash.
            for {
                let end := add(data, mul(mload(proof), 0x20))
            } lt(data, end) {
                data := add(data, 0x20)
            } {
                let loadedData := mload(data)
                switch gt(computedHash, loadedData)
                case 0 {
                    // Store elements to hash contiguously in scratch space.
                    // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                    mstore(0x00, computedHash)
                    mstore(0x20, loadedData)
                    computedHash := keccak256(0x00, 0x40)
                }
                default {
                    mstore(0x00, loadedData)
                    mstore(0x20, computedHash)
                    computedHash := keccak256(0x00, 0x40)
                }
            }
            isValid := eq(computedHash, root)
        }
    }
}
