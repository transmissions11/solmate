// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    error CAST();

    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        if (!(x < 1 << 248)) {
            revert CAST();
        }

        y = uint248(x);
    }

    function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
        if (!(x < 1 << 224)) {
            revert CAST();
        }

        y = uint224(x);
    }

    function safeCastTo192(uint256 x) internal pure returns (uint192 y) {
        if (!(x < 1 << 192)) {
            revert CAST();
        }

        y = uint192(x);
    }

    function safeCastTo160(uint256 x) internal pure returns (uint160 y) {
        if (!(x < 1 << 160)) {
            revert CAST();
        }

        y = uint160(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        if (!(x < 1 << 128)) {
            revert CAST();
        }

        y = uint128(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        if (!(x < 1 << 96)) {
            revert CAST();
        }

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        if (!(x < 1 << 64)) {
            revert CAST();
        }

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        if (!(x < 1 << 32)) {
            revert CAST();
        }

        y = uint32(x);
    }

    function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
        if (!(x < 1 << 8)) {
            revert CAST();
        }

        y = uint8(x);
    }
}
