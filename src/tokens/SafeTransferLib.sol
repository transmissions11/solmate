// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

import "./ERC20.sol";

/// @notice Safe ERC20 and ETH transfer library.
/// @author Uniswap and TransmissionsDev
library SafeTransferLib {
    /// @notice Transfers tokens from the targeted address to the given destination.
    /// @param token The contract address of the token to be transferred.
    /// @param from The originating address from which the tokens will be transferred.
    /// @param to The destination address of the transfer.
    /// @param value The amount to be transferred.
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transferFrom.selector, from, to, value)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    /// @notice Transfers tokens from address(this) to a recipient.
    /// @param token The contract address of the token which will be transferred.
    /// @param to The recipient of the transfer.
    /// @param value The value of the transfer.
    function safeTransfer(
        ERC20 token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transfer.selector, to, value)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    /// @notice Transfers ETH to the recipient address.
    /// @param to The destination of the transfer.
    /// @param value The value to be transferred.
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
    }
}
