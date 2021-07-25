// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Safe arithmetic library with operations for fixed-point numbers.
/// @author Modified from Dappsys V2 (https://github.com/dapphub/ds-math/blob/master/src/math.sol)
library MathHelpers {
    /*///////////////////////////////////////////////////////////////
                            UNIT DEFINITIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant WAD_DECIMALS = 18;
    uint256 internal constant RAY_DECIMALS = 27;
    uint256 internal constant RAD_DECIMALS = 45;

    uint256 internal constant WAD = 10**WAD_DECIMALS;
    uint256 internal constant RAY = 10**RAY_DECIMALS;
    uint256 internal constant RAD = 10**RAD_DECIMALS;

    /*///////////////////////////////////////////////////////////////
                             WAD OPERATORS
    //////////////////////////////////////////////////////////////*/

    function wmul(uint256 x, uint256 wad) internal pure returns (uint256 z) {
        z = (x * wad) / WAD;
    }

    function wdiv(uint256 x, uint256 wad) internal pure returns (uint256 z) {
        z = (x * WAD) / wad;
    }

    /*///////////////////////////////////////////////////////////////
                           RAY OPERATORS
    //////////////////////////////////////////////////////////////*/

    function rmul(uint256 x, uint256 ray) internal pure returns (uint256 z) {
        z = (x * ray) / RAY;
    }

    function rdiv(uint256 x, uint256 ray) internal pure returns (uint256 z) {
        z = (x * RAY) / ray;
    }

    /*///////////////////////////////////////////////////////////////
                          GENERAL NUMBER UTILS
    //////////////////////////////////////////////////////////////*/

    function pow(
        uint256 base,
        uint256 exponent,
        uint256 decimals
    ) internal pure returns (uint256 z) {
        assembly {
            switch base
            case 0 {
                switch exponent
                case 0 {
                    z := decimals
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(exponent, 2)
                case 0 {
                    z := decimals
                }
                default {
                    z := base
                }
                let half := div(decimals, 2) // for rounding.
                for {
                    exponent := div(exponent, 2)
                } exponent {
                    exponent := div(exponent, 2)
                } {
                    let xx := mul(base, base)
                    if iszero(eq(div(xx, base), base)) {
                        revert(0, 0)
                    }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    base := div(xxRound, decimals)
                    if mod(exponent, 2) {
                        let zx := mul(z, base)
                        if and(iszero(iszero(base)), iszero(eq(div(zx, base), z))) {
                            revert(0, 0)
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, decimals)
                    }
                }
            }
        }
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /*///////////////////////////////////////////////////////////////
                            MIN MAX UTILS
    //////////////////////////////////////////////////////////////*/

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }
}
