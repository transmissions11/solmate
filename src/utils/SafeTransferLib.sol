// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            // Fill up the scratch space so if the call <32 bytes, we can tell without branching.
            mstore(0, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            // We'll copy up to 32 bytes of return data into the scratch space,
            // if it returns <32 bytes at least a portion of the junk will remain.
            success := call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)

            // Set success to whether the call returned 1, except if it
            // had no return data, in which case we assume it succeeded,
            // or if it reverted, in which case we multiply everything by
            // 0, setting success to zero which will decode as false below.
            success := mul(add(iszero(returndatasize()), eq(mload(0), 1)), success)
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            // Fill up the scratch space so if the call <32 bytes, we can tell without branching.
            mstore(0, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            // We'll copy up to 32 bytes of return data into the scratch space,
            // if it returns <32 bytes at least a portion of the junk will remain.
            success := call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)

            // Set success to whether the call returned 1, except if it
            // had no return data, in which case we assume it succeeded,
            // or if it reverted, in which case we multiply everything by
            // 0, setting success to zero which will decode as false below.
            success := mul(add(iszero(returndatasize()), eq(mload(0), 1)), success)
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            // Fill up the scratch space so if the call <32 bytes, we can tell without branching.
            mstore(0, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            // We'll copy up to 32 bytes of return data into the scratch space,
            // if it returns <32 bytes at least a portion of the junk will remain.
            success := call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)

            // Set success to whether the call returned 1, except if it
            // had no return data, in which case we assume it succeeded,
            // or if it reverted, in which case we multiply everything by
            // 0, setting success to zero which will decode as false below.
            success := mul(add(iszero(returndatasize()), eq(mload(0), 1)), success)
        }

        require(success, "APPROVE_FAILED");
    }
}
