// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Library for converting between addresses and bytes32 values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Bytes32AddressLib.sol)
library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address _addr) {
        assembly{
          //shift bytesValue to the right 96 times, eventually removing the last 12bytes hence leaving us with 20 bytes left
          _addr := shr(96, bytesValue)
        }
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32 _bytes) {
        assembly{
          _bytes := shl(96, addressValue)
        }
    }
}
