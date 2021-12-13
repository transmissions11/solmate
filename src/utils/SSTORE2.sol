// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Modified from 0xSequence (https://github.com/0xsequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's null to ensure the contract can't be called.

    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a zero byte to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        // Compute the creation code we need from our desired runtime code.
        bytes memory creationCode = abi.encodePacked(
            //--------------------------------------------------------------------------------//
            // Opcode     | Opcode + Arguments  | Description        | Stack View             //
            //--------------------------------------------------------------------------------//
            // 0x63       |  0x63XXXXXX         | PUSH4 codeSize     | codeSize               //
            // 0x80       |  0x80               | DUP1               | codeSize codeSize      //
            // 0x60       |  0x600e             | PUSH1 14           | 14 codeSize codeSize   //
            // 0x60       |  0x6000             | PUSH1 00           | 0 14 codeSize codeSize //
            // 0x39       |  0x39               | CODECOPY           | codeSize               //
            // 0x60       |  0x6000             | PUSH1 00           | 0 codeSize             //
            // 0xf3       |  0xf3               | RETURN             |                        //
            //--------------------------------------------------------------------------------//
            hex"63", // We use a 4 byte PUSH for future proofing, but in theory we could use a smaller PUSH.
            uint32(runtimeCode.length), // We must cast it to a 32 bit number (4 bytes) as we use a PUSH4 above.
            // If we used a smaller PUSH we'd need to change 0E (14 in hex) as it's used as the size of the creation code.
            hex"80_60_0E_60_00_39_60_00_F3", // Optimized constructor code, copies the runtime code into memory and returns it.
            runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        // If the pointer is 0 then the deployment failed.
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
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // we move the free memory pointer to the start of the next empty 32 byte slot.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first slot (32 bytes) of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}
