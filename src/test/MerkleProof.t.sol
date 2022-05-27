// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MerkleProof} from "../utils/MerkleProof.sol";

contract MerkleProofTest is DSTestPlus {
    function testVerifyEmpty(
        bool nonEmptyRoot,
        bool hasProof,
        bool nonEmptyProof,
        bool nonEmptyLeaf
    ) public {
        bytes32 root;
        if (nonEmptyRoot) {
            root = bytes32("a");
        }
        bytes32[] memory proof;
        if (hasProof) {
            proof = new bytes32[](1);
            proof[0] = nonEmptyProof ? bytes32("a") : bytes32(0);
        }
        bytes32 leaf;
        if (nonEmptyLeaf) {
            leaf = bytes32("a");
        }
        bool isValid = leaf == root && proof.length == 0;
        assertBoolEq(this.verify(proof, root, leaf), isValid);
    }

    function testVerifyValidProof() public {
        testVerifyProof(false, false, false, 0x00);
    }

    function testVerifyInvalidProof() public {
        testVerifyProof(false, false, true, 0x00);
    }

    function testVerifyProof(
        bool damageProof,
        bool damageRoot,
        bool damageLeaf,
        bytes32 randomness
    ) public {
        bool noDamage = true;
        uint256 ri; // Randomness index.

        // Merkle tree created from leaves ['a', 'b', 'c'].
        // Leaf is 'a'.
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        proof[1] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        if (damageProof) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % proof.length;
            proof[i] = bytes32(uint256(proof[i]) ^ 1); // Flip a bit.
        }

        bytes32 root = 0x5842148bc6ebeb52af882a317c765fccd3ae80589b21a9b8cbf21abb630e46a7;
        if (damageRoot) {
            noDamage = false;
            root = bytes32(uint256(root) ^ 1); // Flip a bit.
        }

        bytes32 leaf = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        if (damageLeaf) {
            noDamage = false;
            leaf = bytes32(uint256(leaf) ^ 1); // Flip a bit.
        }

        assertBoolEq(this.verify(proof, root, leaf), noDamage);
    }

    function testMultiProofVerifyEmpty(
        bool nonEmptyRoot,
        bool hasProof,
        bool nonEmptyProof,
        bool hasLeaf,
        bool nonEmptyLeaf,
        bool[] memory flags
    ) public {
        bytes32 root;
        if (nonEmptyRoot) {
            root = bytes32("a");
        }
        bytes32[] memory proofs;
        if (hasProof) {
            proofs = new bytes32[](1);
            proofs[0] = nonEmptyProof ? bytes32("a") : bytes32(0);
        }
        bytes32[] memory leafs;
        if (hasLeaf) {
            leafs = new bytes32[](1);
            leafs[0] = nonEmptyLeaf ? bytes32("a") : bytes32(0);
        }
        bool isValid = leafs.length > 0 && leafs[0] == root && (proofs.length + leafs.length == flags.length + 1);
        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), isValid);
    }

    function testMultiProofVerifyValidProof() public {
        testMultiProofVerify(false, false, false, false, 0x00);
    }

    function testMultiProofVerifyInvalidProof() public {
        testMultiProofVerify(false, false, true, false, 0x00);
    }

    function testMultiProofVerify(
        bool damageRoot,
        bool damageLeafs,
        bool damageProofs,
        bool damageFlags,
        bytes32 randomness
    ) public {
        bool noDamage = true;
        uint256 ri; // Randomness index.

        // Merkle tree created from ['a', 'b', 'c', 'd', 'e', 'f'].
        // Leafs are ['b', 'f', 'd'].
        bytes32 root = 0x1b404f199ea828ec5771fb30139c222d8417a82175fefad5cd42bc3a189bd8d5;
        if (damageRoot) {
            noDamage = false;
            root = bytes32(uint256(root) ^ 1); // Flip a bit.
        }

        bytes32[] memory leafs = new bytes32[](3);
        leafs[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        leafs[1] = 0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483;
        leafs[2] = 0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3;
        if (damageLeafs) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % leafs.length;
            leafs[i] = bytes32(uint256(leafs[i]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete leafs;
        }

        bytes32[] memory proofs = new bytes32[](2);
        proofs[0] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        proofs[1] = 0x7dea550f679f3caab547cbbc5ee1a4c978c8c039b572ba00af1baa6481b88360;
        if (damageProofs) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % proofs.length;
            proofs[i] = bytes32(uint256(proofs[i]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete proofs;
        }

        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = true;
        flags[2] = false;
        flags[3] = true;
        if (damageFlags) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % flags.length;
            flags[i] = !flags[i]; // Flip a bool.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete flags;
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
