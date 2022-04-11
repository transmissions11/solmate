// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Bitwise library with operations for bit strings and integers.
library BitwiseLib {
    // Integer log2
    // Closely related to count-leading-zeros.
    // See <https://en.wikipedia.org/wiki/Find_first_set>
    // @returns floor(log2(x)) if x is nonzero, otherwise 0.
    //          This is the same as the location of the highest set bit.
    // Consumes 232 gas. This could have been an 3 gas EVM opcode though.
    function ilog2(uint256 x) internal returns (uint256 r) {
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, shl(1, lt(0x3, shr(r, x))))
            r := or(r, lt(0x1, shr(r, x)))
        }
    }
}
