// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for computing contract addresses from their deployer and nonce.
/// @author SolDAO (https://github.com/Sol-DAO/solady/blob/main/src/utils/LibRLP.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibRLP.sol)
library LibRLP {
    // prettier-ignore
    function computeAddress(address deployer, uint256 nonce) internal pure returns (address deployed) {
        // @dev The theoretical allowed limit, based on EIP-2681,
        // for an account nonce is 2**64-2: https://eips.ethereum.org/EIPS/eip-2681.

        // Caution! This function will NOT check that the nonce is within the theoretical range.
        // This is for performance, as exceeding the range is extremely impractical.
        // It is the user's responsibility to ensure that the nonce is valid
        // (e.g. no dirty bits after packing / unpacking).
        assembly {
            // prettier-ignore
            for {} 1 {} {
                // The integer zero is treated as an empty byte string,
                // and as a result it only has a length prefix, 0x80,
                // computed via `0x80 + 0`.

                // A one-byte integer in the [0x00, 0x7f] range uses its 
                // own value as a length prefix,
                // there is no additional `0x80 + length` prefix that precedes it.
                if iszero(gt(nonce, 0x7f)) {
                    mstore(0x00, deployer)
                    // Using `mstore8` instead of `or` naturally cleans
                    // any dirty upper bits of `deployer`.
                    mstore8(0x0b, 0x94)
                    mstore8(0x0a, 0xd6)
                    // `shl` 7 is equivalent to multiplying by 0x80.
                    mstore8(0x20, or(shl(7, iszero(nonce)), nonce))
                    deployed := keccak256(0x0a, 0x17)
                    break
                }
                let i := 8
                // Just use a loop to generalize all the way with minimal bytecode size.
                // prettier-ignore
                for {} shr(i, nonce) { i := add(i, 8) } {}
                // `shr` 3 is equivalent to dividing by 8.
                i := shr(3, i)
                // Store in descending slot sequence to overlap the values correctly.
                mstore(i, nonce)
                mstore(0x00, shl(8, deployer))
                mstore8(0x1f, add(0x80, i))
                mstore8(0x0a, 0x94)
                mstore8(0x09, add(0xd6, i))
                deployed := keccak256(0x09, add(0x17, i))
                break
            }
        }
    }
}
