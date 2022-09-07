// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ECDSA.sol";

/// @notice Signature verification helper that supports both ECDSA signatures from EOAs
/// and ERC1271 signatures from smart contract wallets like Argent and Gnosis safe.
/// @author SolDAO (https://github.com/Sol-DAO/solmate/blob/main/src/utils/SignatureCheckerLib.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/SignatureCheckerLib.sol)
library SignatureCheckerLib {
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool isValid) {
        if (signer == address(0)) return false;

        if (ECDSA.recover(hash, signature) == signer) return true;

        assembly {
            // Load the free memory pointer.
            // Simply using the free memory usually costs less if many slots are needed.
            let m := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(m, 0x1626ba7e) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x20), hash)
            mstore(add(m, 0x40), 0x40) // The offset of the `signature` in the calldata.
            // Copy the `signature` and its length over.
            calldatacopy(add(m, 0x60), sub(signature.offset, 0x20), 0x80)

            isValid := and(
                and(
                    // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                    eq(mload(0x00), shl(224, mload(m))),
                    // Whether the returndata is exactly 0x20 bytes (1 word) long .
                    eq(returndatasize(), 0x20)
                ),
                // Whether the staticcall does not revert.
                // This must be placed at the end of the `and` clause,
                // as the arguments are evaluated from right to left.
                staticcall(
                    gas(), // Remaining gas.
                    signer, // The `signer` address.
                    add(m, 0x1c), // Offset of calldata in memory.
                    0xc4, // Length of calldata in memory.
                    0x00, // Offset of returndata.
                    0x20 // Length of returndata to write.
                )
            )
        }
    }
}
