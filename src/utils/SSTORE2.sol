// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Modified from 0xSequence (https://github.com/0xsequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1;

    function write(bytes memory data) internal returns (address pointer) {
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            hex"63",
            uint32(runtimeCode.length),
            hex"80_60_0E_60_00_39_60_00_F3",
            runtimeCode
        );

        assembly {
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), "DEPLOYMENT_ERROR");
    }

    function read(address pointer) internal view returns (bytes memory data) {
        // This will revert if DATA_OFFSET > code.length.
        uint256 size = pointer.code.length - DATA_OFFSET;

        assembly {
            data := mload(0x40)
            mstore(0x40, add(data, and(add(add(size, add(DATA_OFFSET, 0x20)), 0x1f), not(0x1f))))
            mstore(data, size)
            extcodecopy(pointer, add(data, 0x20), DATA_OFFSET, size)
        }
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory data) {
        // Properly offset input.
        start += DATA_OFFSET;

        // This will revert if start > code.length.
        uint256 size = pointer.code.length - start;

        assembly {
            data := mload(0x40)
            mstore(0x40, add(data, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
            mstore(data, size)
            extcodecopy(pointer, add(data, 0x20), start, size)
        }
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory data) {
        // Properly offset inputs.
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        // This will revert if start > end.
        uint256 size = end - start;

        require(pointer.code.length >= end, "INVALID_RANGE");

        assembly {
            data := mload(0x40)
            mstore(0x40, add(data, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
            mstore(data, size)
            extcodecopy(pointer, add(data, 0x20), start, size)
        }
    }
}
