// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC1155 Token Receiver implementation.
/// @dev Enables accepting safe transfers
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC1155TokenReceiver {

  function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
    return 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
  }

  function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns(bytes4) {
    return 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
  }
}