// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

/// @notice Safe ERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
library SafeERC20 {
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bytes4 selector_ = token.transferFrom.selector;

        assembly {
            // Allocate memory for the call.
            let transferCalldata := mload(0x40)

            // We'll use this mask on our address arguments when assembling calldata.
            let addressMask := 0xffffffffffffffffffffffffffffffffffffffff

            mstore(transferCalldata, selector_) // Begin by writing the transferFrom 4byte selector.
            mstore(add(transferCalldata, 4), and(from, addressMask)) // Add the "from" argument.
            mstore(add(transferCalldata, 36), and(to, addressMask)) // Add the "to" argument.
            mstore(add(transferCalldata, 68), amount) // Now append the "amount" argument.

            // Call transferFrom and store if it reverted or not.
            let callStatus := call(gas(), token, 0, transferCalldata, 100, 0, 0)

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

                // If it returned false:
                if iszero(mload(0)) {
                    // Revert with no reason.
                    revert(0, 0)
                }
            }
            case 0 {
                // If there was no return data, we don't need to do anything.
            }
            default {
                // If the call returned anything else, revert with no reason.
                revert(0, 0)
            }
        }
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bytes4 selector_ = token.transfer.selector;

        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, selector_)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(freeMemoryPointer, 36), amount)

            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            switch returndatasize()
            case 0 {

            }
            case 32 {
                returndatacopy(0, 0, returndatasize())

                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
            default {
                revert(0, 0)
            }
        }
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}
