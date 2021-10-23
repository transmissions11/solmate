// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

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

        require(pointer != address(0), "DEPLOYMENT_FAILED");
    }

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, "OUT_OF_BOUNDS");

        return readBytecode(pointer, start, end - start);
    }

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        assembly {
            data := mload(0x40)
            mstore(0x40, add(data, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
            mstore(data, size)
            extcodecopy(pointer, add(data, 0x20), start, size)
        }
    }
}
