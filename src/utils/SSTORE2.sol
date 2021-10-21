// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";

library SSTORE2 {
    uint256 constant DATA_OFFSET = 1;

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

        require(pointer != address(0), "WRITE_ERROR");
    }

    function read(address pointer) internal view returns (bytes memory code) {
        uint256 codeSize = pointer.code.length;

        if (DATA_OFFSET > codeSize) return new bytes(0);

        unchecked {
            uint256 size = codeSize - DATA_OFFSET;

            assembly {
                code := mload(0x40)
                mstore(0x40, add(code, and(add(add(size, add(DATA_OFFSET, 0x20)), 0x1f), not(0x1f))))
                mstore(code, size)
                extcodecopy(pointer, add(code, 0x20), DATA_OFFSET, size)
            }
        }
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory code) {
        start += DATA_OFFSET;

        uint256 codeSize = pointer.code.length;

        if (start > codeSize) return new bytes(0);

        unchecked {
            uint256 size = codeSize - start;

            assembly {
                code := mload(0x40)
                mstore(0x40, add(code, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
                mstore(code, size)
                extcodecopy(pointer, add(code, 0x20), start, size)
            }
        }
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory code) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        uint256 codeSize = pointer.code.length;

        if (start > codeSize) return new bytes(0);

        require(end > start, "INVALID_RANGE");

        unchecked {
            uint256 reqSize = end - start;
            uint256 maxSize = codeSize - start;

            uint256 size = FixedPointMathLib.min(maxSize, reqSize);

            assembly {
                code := mload(0x40)
                mstore(0x40, add(code, and(add(add(size, add(start, 0x20)), 0x1f), not(0x1f))))
                mstore(code, size)
                extcodecopy(pointer, add(code, 0x20), start, size)
            }
        }
    }
}
