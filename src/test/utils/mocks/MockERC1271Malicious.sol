// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MockERC1271Malicious {
    function isValidSignature(bytes32, bytes calldata) external pure returns (bytes4) {
        assembly {
            mstore(0, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            return(0, 32)
        }
    }
}
