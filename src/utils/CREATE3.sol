// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Bytes32AddressLib} from "./Bytes32AddressLib.sol";

/// @notice Deploy to deterministic addresses without an initcode factor.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/CREATE3.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)
library CREATE3 {
    /*//////////////////////////////////////////////////////////////
                             CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error DeploymentFailed();

    error InitializationFailed();

    /*//////////////////////////////////////////////////////////////
                           BYTECODE CONSTANTS
    //////////////////////////////////////////////////////////////*/

    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //
    // 0x37       |  0x37                 | CALLDATACOPY     |                        //
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //
    // 0xf0       |  0xf0                 | CREATE           | newContract            //
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //
    // 0x52       |  0x52                 | MSTORE           |                        //
    // 0x60       |  0x6008               | PUSH1 08         | 8                      //
    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //
    // 0xf3       |  0xf3                 | RETURN           |                        //
    //--------------------------------------------------------------------------------//
    uint256 internal constant PROXY_BYTECODE = 0x67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3;

    bytes32 internal constant PROXY_BYTECODE_HASH = 0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    /*//////////////////////////////////////////////////////////////
                           CREATE3 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {
        assembly {
            // Store the `PROXY_BYTECODE` into scratch space.
            mstore(0x00, PROXY_BYTECODE)
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            let proxy := create2(0, 0x10, 0x10, salt)

            // If the result of `create2` is the zero address, revert.
            if iszero(proxy) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the proxy's address.
            mstore(0x00, proxy)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            mstore8(0x0a, 0xd6)
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore8(0x0b, 0x94)
            // Nonce of the proxy contract (1).
            mstore8(0x20, 0x01)
            // Shift left and back to clear the upper 96 bits.
            deployed := shr(96, shl(96, keccak256(0x0a, 0x17)))

            // If the deployment is not successful, revert.
            if iszero(
                and(
                    // Whether the deployed address must have a non-zero code size.
                    extcodesize(deployed),
                    // The `call` must be the second argument of the `and`,
                    // as the arguments are evaluated right to left.
                    call(
                        gas(), // Gas remaining.
                        proxy, // Proxy's address.
                        value, // Ether value.
                        add(creationCode, 0x20), // Start of `creationCode`.
                        mload(creationCode), // Length of `creationCode`.
                        0x00, // Offset of output.
                        0x00 // Length of output.
                    )
                )
            ) {
                // Store the function selector of `InitializationFailed()`.
                mstore(0x00, 0x19b991a8)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    function getDeployed(bytes32 salt) internal view returns (address deployed) {
        assembly {
            // Cache the free memory pointer.
            let m := mload(0x40)
            // Store `address(this)`.
            mstore(0x00, address())
            // Store the prefix.
            mstore8(0x0b, 0xff)
            // Store the salt.
            mstore(0x20, salt)
            // Store the bytecode hash.
            mstore(0x40, PROXY_BYTECODE_HASH)

            // Store the proxy's address.
            mstore(0x00, keccak256(0x0b, 0x55))
            // Restore the free memory pointer.
            mstore(0x40, m)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            mstore8(0x0a, 0xd6)
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore8(0x0b, 0x94)
            // Nonce of the proxy contract (1).
            mstore8(0x20, 0x01)
            // Shift left and back to clear the upper 96 bits.
            deployed := shr(96, shl(96, keccak256(0x0a, 0x17)))
        }
    }
}
