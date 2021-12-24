// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
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
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(x == 0 || (x * y) / x == y)
            if iszero(or(iszero(x), eq(div(z, x), y))) {
                revert(0, 0)
            }

            // If baseUnit is zero this will return zero instead of reverting.
            z := div(z, baseUnit)
        }
    }

    function fdiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * baseUnit in z for now.
            z := mul(x, baseUnit)

            if or(
                // Revert if y is zero to ensure we don't divide by zero below.
                iszero(y),
                // Equivalent to require(x == 0 || (x * baseUnit) / x == baseUnit)
                iszero(or(iszero(x), eq(div(z, x), baseUnit)))
            ) {
                revert(0, 0)
            }

            // We ensure y is not zero above, so there is never division by zero here.
            z := div(z, y)
        }
    }

    function fpow(
        uint256 x,
        uint256 n,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0^0 = 1
                    z := baseUnit
                }
                default {
                    // 0^n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store baseUnit in z for now.
                    z := baseUnit
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, baseUnit)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x^2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x))
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, baseUnit)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // Revert if x is non-zero and z * x overflowed.
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                            revert(0, 0)
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, baseUnit)
                    }
                }
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 result) {
        assembly {
            // If x is zero, just return 0.
            if iszero(iszero(x)) {
                // Start off with a result of 1.
                result := 1

                // Used below to help find a nearby power of 2.
                let x2 := x

                // Find the closest power of 2 that is at most x.
                if iszero(lt(x2, 0x100000000000000000000000000000000)) {
                    x2 := shr(128, x2) // Like dividing by 2^128.
                    result := shl(64, result)
                }
                if iszero(lt(x2, 0x10000000000000000)) {
                    x2 := shr(64, x2) // Like dividing by 2^64.
                    result := shl(32, result)
                }
                if iszero(lt(x2, 0x100000000)) {
                    x2 := shr(32, x2) // Like dividing by 2^32.
                    result := shl(16, result)
                }
                if iszero(lt(x2, 0x10000)) {
                    x2 := shr(16, x2) // Like dividing by 2^16.
                    result := shl(8, result)
                }
                if iszero(lt(x2, 0x100)) {
                    x2 := shr(8, x2) // Like dividing by 2^8.
                    result := shl(4, result)
                }
                if iszero(lt(x2, 0x10)) {
                    x2 := shr(4, x2) // Like dividing by 2^4.
                    result := shl(2, result)
                }
                if iszero(lt(x2, 0x8)) {
                    result := shl(1, result)
                }

                // Shifting right by 1 is like dividing by 2.
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))
                result := shr(1, add(result, div(x, result)))

                // Compute a rounded down version of the result.
                let roundedDownResult := div(x, result)

                // If the rounded down result is smaller, use it.
                if gt(result, roundedDownResult) {
                    result := roundedDownResult
                }
            }
        }
    }
}
