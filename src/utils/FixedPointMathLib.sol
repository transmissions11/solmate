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

    /*///////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 result) {
        assembly {
            if iszero(iszero(x)) {
                result := 1

                let xAux := x

                if iszero(lt(xAux, 0x100000000000000000000000000000000)) {
                    xAux := shr(128, xAux)
                    result := shl(64, result)
                }

                if iszero(lt(xAux, 0x10000000000000000)) {
                    xAux := shr(64, xAux)
                    result := shl(32, result)
                }

                if iszero(lt(xAux, 0x100000000)) {
                    xAux := shr(32, xAux)
                    result := shl(16, result)
                }

                if iszero(lt(xAux, 0x10000)) {
                    xAux := shr(16, xAux)
                    result := shl(8, result)
                }

                if iszero(lt(xAux, 0x100)) {
                    xAux := shr(8, xAux)
                    result := shl(4, result)
                }

                if iszero(lt(xAux, 0x10)) {
                    xAux := shr(4, xAux)
                    result := shl(2, result)
                }

                if iszero(lt(xAux, 0x8)) {
                    result := shl(1, result)
                }

                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))
                if eq(result, 0) {
                    revert(0, 0)
                }
                result := shr(1, add(result, div(x, result)))

                if eq(result, 0) {
                    revert(0, 0)
                }
                let roundedDownResult := div(x, result)

                if gt(result, roundedDownResult) {
                    result := roundedDownResult
                }
            }
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x < y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x > y ? x : y;
    }
}
