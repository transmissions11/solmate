// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {MerkleProofLib} from "../src/utils/MerkleProofLib.sol";

contract MerkleProofLibTest is Test {
    function testVerifyProofForHeightOneTree(
        bool hasProof,
        bool nonEmptyProof,
        bool nonEmptyRoot,
        bool nonEmptyLeaf
    ) public {
        bytes32 root;
        if (nonEmptyRoot) {
            root = bytes32("a");
        }
        bytes32 leaf;
        if (nonEmptyLeaf) {
            leaf = bytes32("a");
        }
        bytes32[] memory proof;
        if (hasProof) {
            proof = new bytes32[](1);
            proof[0] = nonEmptyProof ? bytes32("a") : bytes32(0);
        }
        bool isValid = leaf == root && proof.length == 0;
        assertEq(this.verify(proof, root, leaf), isValid);
    }

    function testVerifyProofIsValid() public {
        testVerifyProof(false, false, false, 0x00);
    }

    function testVerifyProofIsInvalid() public {
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

        assertEq(this.verify(proof, root, leaf), noDamage);
    }

    function testVerifyMultiProofForHeightOneTree(
        bool hasProof,
        bool nonEmptyProof,
        bool nonEmptyRoot,
        bool hasLeaf,
        bool nonEmptyLeaf,
        bool[] memory flags
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
        bytes32[] memory leafs;
        if (hasLeaf) {
            leafs = new bytes32[](1);
            leafs[0] = nonEmptyLeaf ? bytes32("a") : bytes32(0);
        }
        bool leafSameAsRoot = leafs.length == 1 && leafs[0] == root;
        bool proofSameAsRoot = proof.length == 1 && proof[0] == root;
        bool isValid = flags.length == 0 && (leafSameAsRoot || proofSameAsRoot) && (leafs.length + proof.length == 1);
        assertEq(this.verifyMultiProof(proof, root, leafs, flags), isValid);
    }

    function testVerifyMultiProofForHeightTwoTree(
        bool allLeafs,
        bool damageRoot,
        bool damageLeafs,
        bool damageProof,
        bool damageFlags,
        bytes32 randomness
    ) public {
        bool noDamage = true;
        uint256 ri; // Randomness index.

        bytes32 leafA = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        bytes32 leafB = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;

        // Merkle tree created from leaves ['a', 'b'].
        bytes32 root = 0x805b21d846b189efaeb0377d6bb0d201b3872a363e607c25088f025b0c6ae1f8;

        bytes32[] memory proof;
        bytes32[] memory leafs;
        bool[] memory flags = new bool[](1);
        flags[0] = allLeafs;

        if (allLeafs) {
            leafs = new bytes32[](2);
            leafs[0] = leafA;
            leafs[1] = leafB;
        } else {
            leafs = new bytes32[](1);
            leafs[0] = leafA;
            proof = new bytes32[](1);
            proof[0] = leafB;
        }

        if (damageRoot) {
            noDamage = false;
            root = bytes32(uint256(root) ^ 1); // Flip a bit.
        }

        if (damageFlags) {
            noDamage = false;
            flags[0] = !flags[0]; // Flip a bool.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete flags;
        }

        if (damageLeafs) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % leafs.length;
            leafs[i] = bytes32(uint256(leafs[i]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete leafs;
        }

        if (damageProof && proof.length != 0) {
            noDamage = false;
            proof[0] = bytes32(uint256(proof[0]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete proof;
        }

        assertEq(this.verifyMultiProof(proof, root, leafs, flags), noDamage);
    }

    function testVerifyMultiProofIsValid() public {
        testVerifyMultiProof(false, false, false, false, 0x00);
    }

    function testVerifyMultiProofIsInvalid() public {
        testVerifyMultiProof(false, false, true, false, 0x00);
    }

    function testVerifyMultiProof(
        bool damageRoot,
        bool damageLeafs,
        bool damageProof,
        bool damageFlags,
        bytes32 randomness
    ) public {
        bool noDamage = true;
        uint256 ri; // Randomness index.

        // Merkle tree created from ['a', 'b', 'c', 'd', 'e', 'f'].
        // Leafs are ['b', 'f', 'd'].
        bytes32 root = 0x1b404f199ea828ec5771fb30139c222d8417a82175fefad5cd42bc3a189bd8d5;

        bytes32[] memory leafs = new bytes32[](3);
        leafs[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        leafs[1] = 0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483;
        leafs[2] = 0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3;

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        proof[1] = 0x7dea550f679f3caab547cbbc5ee1a4c978c8c039b572ba00af1baa6481b88360;

        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = true;
        flags[2] = false;
        flags[3] = true;

        if (damageRoot) {
            noDamage = false;
            root = bytes32(uint256(root) ^ 1); // Flip a bit.
        }

        if (damageLeafs) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % leafs.length;
            leafs[i] = bytes32(uint256(leafs[i]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete leafs;
        }

        if (damageProof) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % proof.length;
            proof[i] = bytes32(uint256(proof[i]) ^ 1); // Flip a bit.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete proof;
        }

        if (damageFlags) {
            noDamage = false;
            uint256 i = uint256(uint8(randomness[ri++])) % flags.length;
            flags[i] = !flags[i]; // Flip a bool.
            if (uint256(uint8(randomness[ri++])) & 1 == 0) delete flags;
        }

        assertEq(this.verifyMultiProof(proof, root, leafs, flags), noDamage);
    }

    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external pure returns (bool) {
        return MerkleProofLib.verify(proof, root, leaf);
    }

    function verifyMultiProof(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32[] calldata leafs,
        bool[] calldata flags
    ) external pure returns (bool) {
        return MerkleProofLib.verifyMultiProof(proof, root, leafs, flags);
    }
}
