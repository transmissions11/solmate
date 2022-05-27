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
        // Merkle tree created from ['a', 'b', 'c', 'd', 'e', 'f'].
        // Leafs are ['b', 'f', 'd'].
        bytes32 root = 0x1b404f199ea828ec5771fb30139c222d8417a82175fefad5cd42bc3a189bd8d5;
        bytes32[] memory leafs = new bytes32[](3);
        leafs[0] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        leafs[1] = 0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483;
        leafs[2] = 0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3;
        bytes32[] memory proofs = new bytes32[](2);
        proofs[0] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        proofs[1] = 0x7dea550f679f3caab547cbbc5ee1a4c978c8c039b572ba00af1baa6481b88360;
        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = true;
        flags[2] = false;
        flags[3] = true;
        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), true);
    }

    function testMultiProofVerifyInvalidProofSupplied() public {
        bytes32 root = 0x1b404f199ea828ec5771fb30139c222d8417a82175fefad5cd42bc3a189bd8d5;
        bytes32[] memory leafs = new bytes32[](3);
        leafs[0] = 0x14bcc435f49d130d189737f9762feb25c44ef5b886bef833e31a702af6be4748;
        leafs[1] = 0xa766932420cc6e9072394bef2c036ad8972c44696fee29397bd5e2c06001f615;
        leafs[2] = 0xea00237ef11bd9615a3b6d2629f2c6259d67b19bb94947a1bd739bae3415141c;
        bytes32[] memory proofs = new bytes32[](0);
        bool[] memory flags = new bool[](2);
        flags[0] = true;
        flags[1] = true;
        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), false);
    }

    function testMultiProofVerifyInvalidProofSupplied1() public {
        bytes32 root = 0x04acaaffeb0baeb707a4247b9e27734c5af34744b6e9e05c53198814cf8e6606;
        bytes32[] memory leafs = new bytes32[](2);
        leafs[0] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        leafs[1] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        bytes32[] memory proofs = new bytes32[](3);
        proofs[0] = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        proofs[1] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        proofs[2] = 0x9c50d01bed947904793eeee1bec5476eba556d9e87045c48d078a31d37826595;
        bool[] memory flags = new bool[](3);
        flags[0] = false;
        flags[1] = false;
        flags[2] = false;
        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), false);
    }

    function testMultiProofVerifyInvalidProofSupplied2() public {
        bytes32 root = 0x04acaaffeb0baeb707a4247b9e27734c5af34744b6e9e05c53198814cf8e6606;
        bytes32[] memory leafs = new bytes32[](2);
        leafs[0] = 0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761;
        leafs[1] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        bytes32[] memory proofs = new bytes32[](3);
        proofs[0] = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        proofs[1] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        proofs[2] = 0x9c50d01bed947904793eeee1bec5476eba556d9e87045c48d078a31d37826595;
        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = false;
        flags[2] = false;
        flags[3] = false;
        assertBoolEq(this.multiProofVerify(root, leafs, proofs, flags), false);
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
