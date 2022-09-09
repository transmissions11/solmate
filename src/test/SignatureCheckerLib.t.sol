// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {SignatureCheckerLib} from "../src/utils/SignatureCheckerLib.sol";
import {MockERC1271Wallet} from "./utils/mocks/MockERC1271Wallet.sol";
import {MockERC1271Malicious} from "./utils/mocks/MockERC1271Malicious.sol";

contract SignatureCheckerLibTest is Test {
    bytes32 constant TEST_MESSAGE = 0x7dbaf558b0a1a5dc7a67202117ab143c1d8605a983e4a743bc06fcc03162dc0d;

    bytes32 constant WRONG_MESSAGE = 0x2d0828dd7c97cff316356da3c16c68ba2316886a0e05ebafb8291939310d51a3;

    address constant SIGNER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    address constant OTHER = address(uint160(1));

    bytes32 constant TEST_SIGNED_MESSAGE_HASH = 0x7d768af957ef8cbf6219a37e743d5546d911dae3e46449d8a5810522db2ef65e;

    bytes32 constant WRONG_SIGNED_MESSAGE_HASH = 0x8cd3e659093d21364c6330514aff328218aa29c2693c5b0e96602df075561952;

    bytes constant SIGNATURE =
        hex"8688e590483917863a35ef230c0f839be8418aa4ee765228eddfcea7fe2652815db01c2c84b0ec746e1b74d97475c599b3d3419fa7181b4e01de62c02b721aea1b";

    bytes constant INVALID_SIGNATURE =
        hex"8688e590483917863a35ef230c0f839be8418aa4ee765228eddfcea7fe2652815db01c2c84b0ec746e1b74d97475c599b3d3419fa7181b4e01de62c02b721aea1b01";

    MockERC1271Wallet mockERC1271Wallet;

    MockERC1271Malicious mockERC1271Malicious;

    function setUp() public {
        mockERC1271Wallet = new MockERC1271Wallet(SIGNER);
        mockERC1271Malicious = new MockERC1271Malicious();
    }

    function testSignatureCheckerOnEOAWithMatchingSignerAndSignature() public {
        assertTrue(this.isValidSignatureNow(SIGNER, TEST_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnEOAWithInvalidSigner() public {
        assertFalse(this.isValidSignatureNow(OTHER, TEST_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnEOAWithWrongSignedMessageHash() public {
        assertFalse(this.isValidSignatureNow(SIGNER, WRONG_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnEOAWithInvalidSignature() public {
        assertFalse(this.isValidSignatureNow(SIGNER, TEST_SIGNED_MESSAGE_HASH, INVALID_SIGNATURE));
    }

    function testSignatureCheckerOnWalletWithMatchingSignerAndSignature() public {
        assertTrue(this.isValidSignatureNow(address(mockERC1271Wallet), TEST_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnWalletWithInvalidSigner() public {
        assertFalse(this.isValidSignatureNow(address(this), TEST_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnWalletWithZeroAddressSigner() public {
        assertFalse(this.isValidSignatureNow(address(0), TEST_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnWalletWithWrongSignedMessageHash() public {
        assertFalse(this.isValidSignatureNow(address(mockERC1271Wallet), WRONG_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function testSignatureCheckerOnWalletWithInvalidSignature() public {
        assertFalse(this.isValidSignatureNow(address(mockERC1271Wallet), TEST_SIGNED_MESSAGE_HASH, INVALID_SIGNATURE));
    }

    function testSignatureCheckerOnMaliciousWallet() public {
        assertFalse(this.isValidSignatureNow(address(mockERC1271Malicious), WRONG_SIGNED_MESSAGE_HASH, SIGNATURE));
    }

    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) external view returns (bool) {
        assembly {
            // Contaminate the upper 96 bits.
            signer := or(shl(160, 1), signer)
        }
        return SignatureCheckerLib.isValidSignatureNow(signer, hash, signature);
    }
}
