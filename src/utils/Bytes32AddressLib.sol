// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Library for converting between addresses and bytes32 values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Bytes32AddressLib.sol)
library Bytes32AddressLib {
    /**
     * @notice fromLast20Bytes() is a function that takes a bytes32 value and returns an address.
     * @dev The function first converts the bytes32 value to a uint256, then to a uint160, and finally to an address. 
     */
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }

    /**
     * @notice fillLast12Bytes() is a pure function that takes an address and returns the last 12 bytes of the address as a bytes32.
     * @dev This function is used to convert an address to a bytes32.
     */
    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
    }
}
