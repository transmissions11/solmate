// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

library MerkleProof {
    function verify(
        bytes32 root,
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bool isValid) {
        assembly {
            let computedHash := leaf
            let proofLength := mload(proof)

            // exit early if empty proof is supplied
            if iszero(proofLength) {
                revert(0, 0)
            }

            // get first value for loop
            let data := add(proof, 0x20)
            for {let end := add(data, mul(proofLength, 0x20))}
            lt(data, end)
            { data := add(data, 0x20) } {
                switch iszero(gt(computedHash, data))
                case 0 {
                    mstore(0x00, computedHash)
                    mstore(0x20, data)
                    computedHash := keccak256(0x00, 0x40)
                }
                default {
                    mstore(0x00, data)
                    mstore(0x20, computedHash)
                    computedHash := keccak256(0x00, 0x40)
                }
            }
            isValid := eq(computedHash, root)
        }
    }
}