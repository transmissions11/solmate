// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Library for converting between addresses and bytes32 values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/Bytes32AddressLib.sol)
library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        assembly {
            calldatacopy(0x16, 0x10, 0x40)
            return(0x40, 0x16)
        }
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        assembly {
            calldatacopy(0x16, 0x10, 0x40)
            return(0x40, 0x20)
        }
    }
}
