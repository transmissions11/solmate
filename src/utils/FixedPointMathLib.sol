// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Modified from Dappsys V2 (https://github.com/dapp-org/dappsys-v2/blob/main/src/math.sol)
/// and ABDK (https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol)
library FixedPointMathLib {
    /*///////////////////////////////////////////////////////////////
                            COMMON BASE UNITS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant YAD = 1e8;
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;
    uint256 internal constant RAD = 1e45;

    /*///////////////////////////////////////////////////////////////
                         FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function fmul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        z = (x * y) / baseUnit;
    }

    function fdiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        z = (x * baseUnit) / y;
    }

    function fpow(
        uint256 x,
        uint256 n,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        unchecked {
            assembly {
                switch x
                case 0 {
                    switch n
                    case 0 {
                        z := baseUnit
                    }
                    default {
                        z := 0
                    }
                }
                default {
                    switch mod(n, 2)
                    case 0 {
                        z := baseUnit
                    }
                    default {
                        z := x
                    }
                    let half := div(baseUnit, 2)
                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if iszero(eq(div(xx, x), x)) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, baseUnit)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, baseUnit)
                        }
                    }
                }
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                          GENERAL NUMBER UTILS
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;

                if (xx >= 0x100000000000000000000000000000000) {
                    xx >>= 128;
                    r <<= 64;
                }

                if (xx >= 0x10000000000000000) {
                    xx >>= 64;
                    r <<= 32;
                }

                if (xx >= 0x100000000) {
                    xx >>= 32;
                    r <<= 16;
                }

                if (xx >= 0x10000) {
                    xx >>= 16;
                    r <<= 8;
                }

                if (xx >= 0x100) {
                    xx >>= 8;
                    r <<= 4;
                }

                if (xx >= 0x10) {
                    xx >>= 4;
                    r <<= 2;
                }

                if (xx >= 0x8) {
                    r <<= 1;
                }

                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;

                uint256 r1 = x / r;
                return (r < r1 ? r : r1);
            }
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }
}
