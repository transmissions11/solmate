// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    /**
     * @notice safeCastTo248 is a function that takes a uint256 and returns a uint248.
     * @dev The function requires that the uint256 is less than 2^248, and then casts it to a uint248.
     */
    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        require(x < 1 << 248);

        y = uint248(x);
    }

    /**
     * @notice This function is used to safely cast a uint256 to a uint224.
     * @dev This function requires that the uint256 is less than 1 << 224. If this is not the case, the function will revert.
     */
    function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
        require(x < 1 << 224);

        y = uint224(x);
    }

    /**
     * @notice This function is used to safely cast a uint256 to a uint192.
     * @dev This function requires that the uint256 is less than 1 << 192. If this is not the case, the function will revert.
     */
    function safeCastTo192(uint256 x) internal pure returns (uint192 y) {
        require(x < 1 << 192);

        y = uint192(x);
    }

    /**
     * @notice safeCastTo160() is a function that takes a uint256 and casts it to a uint160.
     * @dev This function requires that the uint256 is less than 2^160. If this is not the case, the function will throw an error.
     */
    function safeCastTo160(uint256 x) internal pure returns (uint160 y) {
        require(x < 1 << 160);

        y = uint160(x);
    }

    /**
     * @notice safeCastTo128() is a function that takes a uint256 and casts it to a uint128.
     * @dev This function requires that the uint256 is less than 2^128. If it is not, the function will throw an error.
     */
    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        require(x < 1 << 128);

        y = uint128(x);
    }

    /**
     * @notice safeCastTo96() is a function that takes in a uint256 and returns a uint96.
     * @dev The function requires that the input is less than 2^96, and then casts the input to a uint96.
     */
    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        require(x < 1 << 96);

        y = uint96(x);
    }

    /**
     * @notice safeCastTo64() is a function that takes a uint256 and returns a uint64.
     * @dev This function requires that the uint256 is less than 2^64. If the uint256 is greater than 2^64, the function will throw an error. The function casts the uint256 to a uint64. 
     */
    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        require(x < 1 << 64);

        y = uint64(x);
    }

    /**
     * @notice safeCastTo32 is a function that takes a uint256 and returns a uint32.
     * @dev This function requires that the input is less than 2^32. If the input is greater than 2^32, the function will throw an error. The function casts the input to a uint32 and returns it. 
     */
    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        require(x < 1 << 32);

        y = uint32(x);
    }

    /**
     * @notice safeCastTo24() is a function that takes a uint256 and returns a uint24.
     * @dev The function requires that the input is less than 2^24, and then casts the input to a uint24. 
     */
    function safeCastTo24(uint256 x) internal pure returns (uint24 y) {
        require(x < 1 << 24);

        y = uint24(x);
    }

    /**
     * @notice safeCastTo16 is a function that takes a uint256 and casts it to a uint16.
     * @dev The function requires that the uint256 is less than 1 << 16, and then casts it to a uint16.
     */
    function safeCastTo16(uint256 x) internal pure returns (uint16 y) {
        require(x < 1 << 16);

        y = uint16(x);
    }

    /**
     * @notice safeCastTo8() is a function that takes a uint256 and returns a uint8.
     * @dev The function requires that the input is less than 1 << 8, and then casts the uint256 to a uint8. 
     */
    function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
        require(x < 1 << 8);

        y = uint8(x);
    }
}
