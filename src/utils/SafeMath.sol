// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

/// @notice Optimized overflow and underflow safe math operations.
/// @dev Do not use this library with Solidity versions >=0.8.0, it is unnecessary, as these checks are integrated natively.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/LowGasSafeMath.sol)
library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}
