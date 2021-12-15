// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC1155TokenReceiver} from "./ERC1155TokenReceiver.sol";

/// @notice Modern and gas efficient ERC1155 implementation.
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC1155 is ERC1155TokenReceiver {

  /*///////////////////////////////////////////////////////////////
                            ERC1155 STORAGE
  //////////////////////////////////////////////////////////////*/

  /// @dev onReceive function signatures
  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;

  /*///////////////////////////////////////////////////////////////
                                EVENTS
  //////////////////////////////////////////////////////////////*/

  event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 amount);

  event TransferBatch(address indexed operator, address indexed _from, address indexed _to, uint256[] ids, uint256[] amounts);

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /*///////////////////////////////////////////////////////////////
                    Public Transfer Functions
  //////////////////////////////////////////////////////////////*/

  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require((msg.sender == from) || isApprovedForAll(from, msg.sender), "INVALID_OPERATOR");
    require(to != address(0), "INVALID_RECIPIENT");
    // require(amount <= balances[from][id]) is not necessary since checked with safemath operations

    _safeTransferFrom(from, to, id, amount);
    _callonERC1155Received(from, to, id, amount, gasleft(), data);
  }

  function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
    require((msg.sender == from) || isApprovedForAll(from, msg.sender), "INVALID_OPERATOR");
    require(to != address(0), "INVALID_RECIPIENT");

    _safeBatchTransferFrom(from, to, ids, amounts);
    _callonERC1155BatchReceived(from, to, ids, amounts, gasleft(), data);
  }

  /*///////////////////////////////////////////////////////////////
                    Internal Transfer Functions
  //////////////////////////////////////////////////////////////*/

  function _safeTransferFrom(address from, address to, uint256 id, uint256 amount) internal {
    balances[from][id] = balances[from][id] - amount;
    balances[to][id] = balances[to][id] + amount;

    emit TransferSingle(msg.sender, from, to, id, amount);
  }

  function _callonERC1155Received(address from, address to, uint256 id, uint256 amount, uint256 gasLimit, bytes memory data) internal {
    if (to.code.length > 0) {
      bytes4 retval = ERC1155TokenReceiver(to).onERC1155Received{gas: gasLimit}(msg.sender, from, id, amount, data);
      require(retval == ERC1155_RECEIVED_VALUE, "INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  function _safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts) internal {
    require(ids.length == amounts.length, "INVALID_ARRAYS_LENGTH");

    uint256 nTransfer = ids.length;
    for (uint256 i = 0; i < nTransfer; i++) {
      balances[from][ids[i]] = balances[from][ids[i]] - amounts[i];
      balances[to][ids[i]] = balances[to][ids[i]] + amounts[i];
    }

    emit TransferBatch(msg.sender, from, to, ids, amounts);
  }

  function _callonERC1155BatchReceived(address from, address to, uint256[] memory ids, uint256[] memory amounts, uint256 gasLimit, bytes memory data) internal {
    if (to.code.length > 0) {
      bytes4 retval = ERC1155TokenReceiver(to).onERC1155BatchReceived{gas: gasLimit}(msg.sender, from, ids, amounts, data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  /*///////////////////////////////////////////////////////////////
                        Operator Functions
  //////////////////////////////////////////////////////////////*/

  function setApprovalForAll(address operator, bool approved) external override {
    operators[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function isApprovedForAll(address owner, address operator) public override view returns (bool isOperator) {
    return operators[owner][operator];
  }

  /*///////////////////////////////////////////////////////////////
                        Balance Functions
  //////////////////////////////////////////////////////////////*/

  function balanceOf(address owner, uint256 id) public override view returns (uint256) {
    return balances[owner][id];
  }

  function balanceOfBatch(address[] memory owners, uint256[] memory ids) public override view returns (uint256[] memory) {
    require(owners.length == ids.length, "INVALID_ARRAY_LENGTH");

    uint256[] memory batchBalances = new uint256[](owners.length);
    for (uint256 i = 0; i < owners.length; i++) {
      batchBalances[i] = balances[owners[i]][ids[i]];
    }

    return batchBalances;
  }

  /*///////////////////////////////////////////////////////////////
                        ERC165 Functions
  //////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 interfaceID) public override virtual pure returns (bool) {
    return interfaceID == this.supportsInterface.selector;
  }
}