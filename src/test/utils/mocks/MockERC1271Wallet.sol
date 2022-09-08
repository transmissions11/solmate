// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../src/utils/ECDSA.sol";

contract MockERC1271Wallet {
    address signer;

    constructor(address signer_) {
        signer = signer_;
    }

    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4) {
        return ECDSA.recover(hash, signature) == signer ? bytes4(0x1626ba7e) : bytes4(0);
    }
}
