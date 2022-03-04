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

            // exit early if proof is empty supplied
            if iszero(proofLength) {
                isValid := 0
                revert(0, 0)
            }

            let data := add(proof, 0x20)
            let p := mload(0x40)
            mstore(0x40, add(p, 64))
            for {let end := add(data, mul(proofLength, 0x20))}
            lt(data, end) 
            { data := add(data, 0x20) } {
                switch iszero(gt(computedHash, data))
                case 0 {
                    mstore(add(p, 32), computedHash)
                    mstore(add(p, 64), data)
                    computedHash := keccak256(p, 64)
                }
                default {
                    mstore(add(p, 32), data)
                    mstore(add(p, 64), computedHash)
                    computedHash := keccak256(p, 64)
                }
            }
            isValid := eq(computedHash, root)
        }
    }
}