// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MerkleProof} from "../utils/MerkleProof.sol";

contract MerkleProofTest is DSTestPlus {
    function testVerifyEmptyMerkleProofSuppliedLeafAndRootSame() public {
        bytes32[] memory proof;
        assertBoolEq(this.verify(proof, 0x00, 0x00), true);
    }

    function testVerifyEmptyMerkleProofSuppliedLeafAndRootDifferent() public {
        bytes32[] memory proof;
        bytes32 leaf = "a";
        assertBoolEq(this.verify(proof, 0x00, leaf), false);
    }

    function testValidProofSupplied() public {
        // Merkle tree created from leaves ['a', 'b', 'c'].
        // Leaf is 'a'.
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        proof[1] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        bytes32 root = 0x5842148bc6ebeb52af882a317c765fccd3ae80589b21a9b8cbf21abb630e46a7;
        bytes32 leaf = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        assertBoolEq(this.verify(proof, root, leaf), true);
    }

    function testVerifyInvalidProofSupplied() public {
        // Merkle tree created from leaves ['a', 'b', 'c'].
        // Leaf is 'a'.
        // Proof is same as testValidProofSupplied but last byte of first element is modified.
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5511;
        proof[1] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        bytes32 root = 0x5842148bc6ebeb52af882a317c765fccd3ae80589b21a9b8cbf21abb630e46a7;
        bytes32 leaf = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        assertBoolEq(this.verify(proof, root, leaf), false);
    }

    function testMultiProofVerifyValidProofSupplied() public {
        testMultiProofVerify(0, 0, 0, 0);
    }

    function testMultiProofVerifyInvalidProofSupplied() public {
        testMultiProofVerify(0, 0, 2, 0);
    }

    function testMultiProofVerify(
        uint256 rootDamage,
        uint256 leafsDamage,
        uint256 proofsDamage,
        uint256 flagsDamage
    ) public {
        bool noDamage = true;

        // Merkle tree created from ['a', 'b', 'c', 'd', 'e', 'f'].
        // Leafs are ['b', 'f', 'd'].
        bytes32 root = 0x1b404f199ea828ec5771fb30139c222d8417a82175fefad5cd42bc3a189bd8d5;
        if (rootDamage != 0) {
            noDamage = false;
            root = bytes32(uint256(root) ^ rootDamage);
        }

        bytes32[] memory leafs = new bytes32[](3);
        leafs[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        leafs[1] = 0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483;
        leafs[2] = 0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3;
        if (leafsDamage != 0) {
            noDamage = false;
            uint256 i = leafsDamage % leafs.length;
            leafs[i] = bytes32(uint256(leafs[i]) ^ leafsDamage);
            if (leafsDamage == 1) {
                leafs = new bytes32[](0);
            }
        }

        bytes32[] memory proofs = new bytes32[](2);
        proofs[0] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        proofs[1] = 0x7dea550f679f3caab547cbbc5ee1a4c978c8c039b572ba00af1baa6481b88360;
        if (proofsDamage != 0) {
            noDamage = false;
            uint256 i = proofsDamage % proofs.length;
            proofs[i] = bytes32(uint256(proofs[i]) ^ proofsDamage);
            if (proofsDamage == 1) {
                proofs = new bytes32[](0);
            }
        }

        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = true;
        flags[2] = false;
        flags[3] = true;
        if (flagsDamage != 0) {
            noDamage = false;
            uint256 i = flagsDamage % flags.length;
            flags[i] = !flags[i];
            if (flagsDamage == 1) {
                flags = new bool[](0);
            }
        }

        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), noDamage);
    }

    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function multiProofVerify(
        bytes32 root,
        bytes32[] calldata leafs,
        bytes32[] calldata proofs,
        bool[] calldata flags
    ) external pure returns (bool) {
        return MerkleProof.multiProofVerify(root, leafs, proofs, flags);
    }
}
