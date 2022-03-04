// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MerkleProof} from "../utils/MerkleProof.sol";

contract MerkleProofTest is DSTestPlus {

    function testFailVerifyNoProofSupplied() public pure {
        bytes32[] memory c;
        MerkleProof.verify(bytes32(0), c, bytes32(0));
    }

    function testFailInvalidProofSupplied() public {

    }

    function testVerifyValidProofSupplied_Trivial() public {
    }

    function testVerifyValidProofSupplied_ManyNodes() public {

    }

}
