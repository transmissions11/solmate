// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
contract SafeCastLib {

    uint256 internal constant MAX_UINT248 = 2**248 - 1;
    uint256 internal constant MAX_UINT224 = 2**224 - 1;
    uint256 internal constant MAX_UINT128 = 2**128 - 1;
    uint256 internal constant MAX_UINT112 = 2**112 - 1;
    uint256 internal constant MAX_UINT96  = 2**96  - 1;
    uint256 internal constant MAX_UINT64  = 2**64  - 1;
    uint256 internal constant MAX_UINT32  = 2**32  - 1;
    uint256 internal constant MAX_UINT16  = 2**16  - 1;
    uint256 internal constant MAX_UINT8   = 2**8   - 1;


    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        if (x > MAX_UINT248) revert();

        y = uint248(x);
    }

    function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
        if (x > MAX_UINT224) revert();

        y = uint224(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        if (x > MAX_UINT128) revert();

        y = uint128(x);
    }

    function safeCastTo112(uint256 x) internal pure returns (uint112 y) {
        if (x > MAX_UINT112) revert();

        y = uint112(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        if (x > MAX_UINT96) revert();

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        if (x > MAX_UINT64) revert();

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        if (x > MAX_UINT32) revert();

        y = uint32(x);
    }

    function safeCastTo16(uint256 x) internal pure returns (uint16 y) {
        if (x > MAX_UINT16) revert();

        y = uint16(x);
    }

    function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
        if (x > MAX_UINT8) revert();

        y = uint8(x);
    }
}
