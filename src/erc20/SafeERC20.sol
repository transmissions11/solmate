// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

/// @notice Safe ERC20 and ETH transfer library that gracefully handles missing return values.
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
library SafeERC20 {
    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Allocate memory for calldata.
            let callData := mload(0x40)

            // Write the abi-encoded calldata to the slot in memory piece by piece:
            mstore(callData, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(callData, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(callData, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(callData, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it reverted or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            let callStatus := call(gas(), token, 0, callData, 100, 0, 0)

            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the call's return data.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // If it decodes to false:
                if iszero(mload(0)) {
                    // Revert with no message.
                    revert(0, 0)
                }
            }
            case 0 {
                // If there was no return data, we don't need to do anything.
            }
            default {
                // If the call returned anything else, revert with no message.
                revert(0, 0)
            }
        }
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Allocate memory for calldata.
            let callData := mload(0x40)

            // Write the abi-encoded calldata to the slot in memory piece by piece:
            mstore(callData, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(callData, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(callData, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it reverted or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            let callStatus := call(gas(), token, 0, callData, 68, 0, 0)

            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the call's return data.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // If it decodes to false:
                if iszero(mload(0)) {
                    // Revert with no message.
                    revert(0, 0)
                }
            }
            case 0 {
                // If there was no return data, we don't need to do anything.
            }
            default {
                // If the call returned anything else, revert with no message.
                revert(0, 0)
            }
        }
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Allocate memory for calldata.
            let callData := mload(0x40)

            // Write the abi-encoded calldata to the slot in memory piece by piece:
            mstore(callData, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(callData, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(callData, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it reverted or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            let callStatus := call(gas(), token, 0, callData, 68, 0, 0)

            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the call's return data.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // If it decodes to false:
                if iszero(mload(0)) {
                    // Revert with no message.
                    revert(0, 0)
                }
            }
            case 0 {
                // If there was no return data, we don't need to do anything.
            }
            default {
                // If the call returned anything else, revert with no message.
                revert(0, 0)
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            // If the call with ETH attached does not succeed:
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Revert with no message.
                revert(0, 0)
            }
        }
    }
}
