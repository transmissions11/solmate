// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MerkleProofLib} from "../utils/MerkleProofLib.sol";

contract MerkleProofLibTest is DSTestPlus {
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

    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external pure returns (bool) {
        return MerkleProofLib.verify(proof, root, leaf);
    }
}
