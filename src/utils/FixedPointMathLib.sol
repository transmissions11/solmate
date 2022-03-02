// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by Balancer (https://github.com/balancer-labs/balancer-v2-monorepo/tree/master/pkg/solidity-utils/contracts/math)
library FixedPointMathLib {
    /*///////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    function expWad(int256 x) internal pure returns (uint256 z) {
        unchecked {
            assembly {
                // Revert if the exponent x is greater than 130e18 or less than -41e18.
                if or(sgt(x, 130000000000000000000), slt(x, sub(0, 41000000000000000000))) {
                    revert(0, 0)
                }
            }

            if (x < 0) {
                z = expWad(-x); // Compute exp for x as a positive.

                assembly {
                    // Divide it by 1e36, to get the inverse of the result.
                    z := div(1000000000000000000000000000000000000, z)
                }

                return z; // Beyond this if statement we know x is positive.
            }

            z = 1; // Will multiply the result by this at the end. Default to 1 as a no-op, may be increased below.

            if (x >= 128000000000000000000) {
                x -= 128000000000000000000; // 2ˆ7 scaled by 1e18.

                // Because eˆ12800000000000000000 exp'd is too large to fit in 20 decimals, we'll store it unscaled.
                z = 38877084059945950922200000000000000000000000000000000000; // We'll multiply by this at the end.
            } else if (x >= 64000000000000000000) {
                x -= 64000000000000000000; // 2^6 scaled by 1e18.

                // Because eˆ64000000000000000000 exp'd is too large to fit in 20 decimals, we'll store it unscaled.
                z = 6235149080811616882910000000; // We'll multiply by this at the end, assuming x is large enough.
            }

            x *= 100; // Scale x to 20 decimals for extra precision.

            uint256 precomputed = 1e20; // Will store the product of precomputed powers of 2 (which almost add up to x) exp'd.

            assembly {
                if iszero(lt(x, 3200000000000000000000)) {
                    x := sub(x, 3200000000000000000000) // 2ˆ5 scaled by 1e18.

                    // Multiplied by eˆ3200000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 7896296018268069516100000000000000), 100000000000000000000)
                }

                if iszero(lt(x, 1600000000000000000000)) {
                    x := sub(x, 1600000000000000000000) // 2ˆ4 scaled by 1e18.

                    // Multiplied by eˆ16000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 888611052050787263676000000), 100000000000000000000)
                }

                if iszero(lt(x, 800000000000000000000)) {
                    x := sub(x, 800000000000000000000) // 2ˆ3 scaled by 1e18.

                    // Multiplied by eˆ8000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 2980957987041728274740004), 100000000000000000000)
                }

                if iszero(lt(x, 400000000000000000000)) {
                    x := sub(x, 400000000000000000000) // 2ˆ2 scaled by 1e18.

                    // Multiplied by eˆ4000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 5459815003314423907810), 100000000000000000000)
                }

                if iszero(lt(x, 200000000000000000000)) {
                    x := sub(x, 200000000000000000000) // 2ˆ1 scaled by 1e18.

                    // Multiplied by eˆ2000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 738905609893065022723), 100000000000000000000)
                }

                if iszero(lt(x, 100000000000000000000)) {
                    x := sub(x, 100000000000000000000) // 2ˆ0 scaled by 1e18.

                    // Multiplied by eˆ1000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 271828182845904523536), 100000000000000000000)
                }

                if iszero(lt(x, 50000000000000000000)) {
                    x := sub(x, 50000000000000000000) // 2ˆ-1 scaled by 1e18.

                    // Multiplied by eˆ5000000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 164872127070012814685), 100000000000000000000)
                }

                if iszero(lt(x, 25000000000000000000)) {
                    x := sub(x, 25000000000000000000) // 2ˆ-2 scaled by 1e18.

                    // Multiplied by eˆ250000000000000000 scaled by 1e20 and divided by 1e20.
                    precomputed := div(mul(precomputed, 128402541668774148407), 100000000000000000000)
                }
            }

            // We'll be using the Taylor series for e^x which looks like: 1 + x + (x^2 / 2!) + ... + (x^n / n!)
            // to approximate the exp of the remaining value x not covered by the precomputed product above.
            uint256 term = uint256(x); // Will track each term in the Taylor series, beginning with x.
            uint256 series = 1e20 + term; // The Taylor series begins with 1 plus the first term, x.

            assembly {
                term := div(mul(term, x), 200000000000000000000) // Equal to dividing x^2 by 2e20 as the first term was just x.
                series := add(series, term)

                term := div(mul(term, x), 300000000000000000000) // Equal to dividing x^3 by 6e20 (3!) as the last term was x divided by 2e20.
                series := add(series, term)

                term := div(mul(term, x), 400000000000000000000) // Equal to dividing x^4 by 24e20 (4!) as the last term was x divided by 6e20.
                series := add(series, term)

                term := div(mul(term, x), 500000000000000000000) // Equal to dividing x^5 by 120e20 (5!) as the last term was x divided by 24e20.
                series := add(series, term)

                term := div(mul(term, x), 600000000000000000000) // Equal to dividing x^6 by 720e20 (6!) as the last term was x divided by 120e20.
                series := add(series, term)

                term := div(mul(term, x), 700000000000000000000) // Equal to dividing x^7 by 5040e20 (7!) as the last term was x divided by 720e20.
                series := add(series, term)

                term := div(mul(term, x), 800000000000000000000) // Equal to dividing x^8 by 40320e20 (8!) as the last term was x divided by 5040e20.
                series := add(series, term)

                term := div(mul(term, x), 900000000000000000000) // Equal to dividing x^9 by 362880e20 (9!) as the last term was x divided by 40320e20.
                series := add(series, term)

                term := div(mul(term, x), 1000000000000000000000) // Equal to dividing x^10 by 3628800e20 (10!) as the last term was x divided by 362880e20.
                series := add(series, term)

                term := div(mul(term, x), 1100000000000000000000) // Equal to dividing x^11 by 39916800e20 (11!) as the last term was x divided by 3628800e20.
                series := add(series, term)

                term := div(mul(term, x), 1200000000000000000000) // Equal to dividing x^12 by 479001600e20 (12!) as the last term was x divided by 39916800e20.
                series := add(series, term)
            }

            // Since e^x * e^y equals e^(x+y) we multiply our Taylor series and precomputed exp'd powers of 2 to get the final result scaled by 1e20.
            return (((series * precomputed) / 1e20) * z) / 100; // We divide the final result by 100 to scale it back down to 18 decimals of precision.
        }
    }

    /*///////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // First, divide z - 1 by the denominator and add 1.
            // We allow z - 1 to underflow if z is 0, because we multiply the
            // end result by 0 if z is zero, ensuring we return 0 if z is zero.
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
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
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // Start off with z at 1.
            z := 1

            // Used below to help find a nearby power of 2.
            let y := x

            // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                // Equivalent to 2 ** z.
                z := shl(1, z)
            }

            // Shifting right by 1 is like dividing by 2.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // Compute a rounded down version of z.
            let zRoundDown := div(x, z)

            // If zRoundDown is smaller, use it.
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}
