// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for bit twiddling operations.
/// @author SolDAO (https://github.com/Sol-DAO/solmate/blob/main/src/utils/LibBit.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
library LibBit {
    /// @dev Returns the index of the most significant bit of `x`.
    /// If `x` is zero, returns 256.
    function msb(uint256 x) internal pure returns (uint256 r) {
        assembly {
            r := shl(8, iszero(x))

            r := or(r, shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            x := shr(r, x)
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))

            // prettier-ignore
            r := or(r, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
                0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f))
        }
    }

    /// @dev Returns the index of the least significant bit of `x`.
    /// If `x` is zero, returns 256.
    function lsb(uint256 x) internal pure returns (uint256 r) {
        assembly {
            r := shl(8, iszero(x))

            // Isolate the least significant bit.
            x := and(x, add(not(x), 1))

            r := or(r, shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // prettier-ignore
            r := or(r, byte(shr(251, mul(shr(r, x), shl(224, 0x077cb531))), 
                0x00011c021d0e18031e16140f191104081f1b0d17151310071a0c12060b050a09))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) public pure returns (uint256 c) {
        assembly {
            let max := not(0)
            let isNotMax := lt(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := xor(256, mul(isNotMax, xor(256, shr(248, mul(x, div(max, 255))))))
        }
    }
}
