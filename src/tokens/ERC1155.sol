// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC1155TokenReceiver} from "./ERC1155TokenReceiver.sol";
import {ERC165} from "./ERC165.sol";

/// @notice Modern and gas efficient ERC1155 implementation.
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC1155 is ERC1155TokenReceiver, ERC165 {

  /*///////////////////////////////////////////////////////////////
                            ERC1155 STORAGE
  //////////////////////////////////////////////////////////////*/

  // onReceive function signatures
  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  // Objects balances
  mapping (address => mapping(uint256 => uint256)) internal balances;

  // Operator Functions
  mapping (address => mapping(address => bool)) internal operators;

  /*///////////////////////////////////////////////////////////////
                                EVENTS
  //////////////////////////////////////////////////////////////*/

  /// @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
  /// @dev Operator MUST be msg.sender
  /// @dev When minting/creating tokens, the `from` field MUST be set to `0x0`
  /// @dev When burning/destroying tokens, the `to` field MUST be set to `0x0`
  /// @dev The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
  /// @dev To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `operator`, and a `amount` of 0
  event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 amount);

  /// @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
  /// @dev Operator MUST be msg.sender
  /// @dev When minting/creating tokens, the `_from` field MUST be set to `0x0`
  /// @dev When burning/destroying tokens, the `_to` field MUST be set to `0x0`
  /// @dev The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
  /// @dev To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `operator`, and a `amount` of 0
  event TransferBatch(address indexed operator, address indexed _from, address indexed _to, uint256[] ids, uint256[] amounts);

  /// @dev MUST emit when an approval is updated
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /*///////////////////////////////////////////////////////////////
                    Public Transfer Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Transfers amount amount of an id from the from address to the to address specified
  /// @param from    Source address
  /// @param to      Target address
  /// @param id      ID of the token type
  /// @param amount  Transfered amount
  /// @param data    Additional data with no specified format, sent in call to `to`
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
    require((msg.sender == from) || isApprovedForAll(from, msg.sender), "INVALID_OPERATOR");
    require(to != address(0), "INVALID_RECIPIENT");
    // require(amount <= balances[from][id]) is not necessary since checked with safemath operations

    _safeTransferFrom(from, to, id, amount);
    _callonERC1155Received(from, to, id, amount, gasleft(), data);
  }

  /// @notice Send multiple types of Tokens from the from address to the to address (with safety call)
  /// @param from     Source addresses
  /// @param to       Target addresses
  /// @param ids      IDs of each token type
  /// @param amounts  Transfer amounts per token type
  /// @param data     Additional data with no specified format, sent in call to `to`
  function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
    require((msg.sender == from) || isApprovedForAll(from, msg.sender), "INVALID_OPERATOR");
    require(to != address(0), "INVALID_RECIPIENT");

    _safeBatchTransferFrom(from, to, ids, amounts);
    _callonERC1155BatchReceived(from, to, ids, amounts, gasleft(), data);
  }

  /*///////////////////////////////////////////////////////////////
                    Internal Transfer Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Transfers amount amount of an id from the from address to the to address specified
  /// @param from    Source address
  /// @param to      Target address
  /// @param id      ID of the token type
  /// @param amount  Transfered amount
  function _safeTransferFrom(address from, address to, uint256 id, uint256 amount) internal {
    balances[from][id] = balances[from][id] - amount;
    balances[to][id] = balances[to][id] + amount;

    emit TransferSingle(msg.sender, from, to, id, amount);
  }

  /// @notice Verifies if receiver is contract and if so, calls (to).onERC1155Received(...)
  /// @param from     Source address
  /// @param to       Target address
  /// @param id       ID of the token type
  /// @param amount   Transfered amount
  /// @param gasLimit The gas limit
  /// @param data     Data to call with
  function _callonERC1155Received(address from, address to, uint256 id, uint256 amount, uint256 gasLimit, bytes memory data) internal {
    // Check if recipient is contract using inline code length
    if (to.code.length > 0) {
      bytes4 retval = IERC1155TokenReceiver(to).onERC1155Received{gas: gasLimit}(msg.sender, from, id, amount, data);
      require(retval == ERC1155_RECEIVED_VALUE, "INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  /// @notice Send multiple types of Tokens from the from address to the to address (with safety call)
  /// @param from     Source addresses
  /// @param to       Target addresses
  /// @param ids      IDs of each token type
  /// @param amounts  Transfer amounts per token type
  function _safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts) internal {
    require(ids.length == amounts.length, "INVALID_ARRAYS_LENGTH");

    // Number of transfer to execute
    uint256 nTransfer = ids.length;

    // Executing all transfers
    for (uint256 i = 0; i < nTransfer; i++) {
      // Update storage balance of previous bin
      balances[from][ids[i]] = balances[from][ids[i]] - amounts[i];
      balances[to][ids[i]] = balances[to][ids[i]] + amounts[i];
    }

    emit TransferBatch(msg.sender, from, to, ids, amounts);
  }

  /// @notice Verifies if receiver is contract and if so, calls (to).onERC1155BatchReceived(...)
  /// @param from     Source addresses
  /// @param to       Target addresses
  /// @param ids      IDs of each token type
  /// @param amounts  Transfer amounts per token type
  /// @param gasLimit The gas limit
  /// @param data     Data to call with
  function _callonERC1155BatchReceived(address from, address to, uint256[] memory ids, uint256[] memory amounts, uint256 gasLimit, bytes memory data) internal {
    // Pass data if recipient is contract
    if (to.code.length > 0) {
      bytes4 retval = IERC1155TokenReceiver(to).onERC1155BatchReceived{gas: gasLimit}(msg.sender, from, ids, amounts, data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  /*///////////////////////////////////////////////////////////////
                        Operator Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
  /// @param operator  Address to add to the set of authorized operators
  /// @param approved  True if the operator is approved, false to revoke approval
  function setApprovalForAll(address operator, bool approved) external override {
    // Update operator status
    operators[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  /// @notice Queries the approval status of an operator for a given owner
  /// @param owner     The owner of the Tokens
  /// @param operator  Address of authorized operator
  /// @return isOperator True if the operator is approved, false if not
  function isApprovedForAll(address owner, address operator) public override view returns (bool isOperator) {
    return operators[owner][operator];
  }


  /*///////////////////////////////////////////////////////////////
                        Balance Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Get the balance of an account's Tokens
  /// @param owner  The address of the token holder
  /// @param id     ID of the Token
  /// @return The owner's balance of the Token type requested
  function balanceOf(address owner, uint256 id) public override view returns (uint256) {
    return balances[owner][id];
  }

  /// @notice Get the balance of multiple account/token pairs
  /// @param owners The addresses of the token holders
  /// @param ids    ID of the Tokens
  /// @return       The owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
  function balanceOfBatch(address[] memory owners, uint256[] memory ids) public override view returns (uint256[] memory) {
    require(owners.length == ids.length, "INVALID_ARRAY_LENGTH");

    // Variables
    uint256[] memory batchBalances = new uint256[](owners.length);

    // Iterate over each owner and token ID
    for (uint256 i = 0; i < owners.length; i++) {
      batchBalances[i] = balances[owners[i]][ids[i]];
    }

    return batchBalances;
  }

  /*///////////////////////////////////////////////////////////////
                        ERC165 Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Query if a contract implements an interface
  /// @param interfaceID  The interface identifier, as specified in ERC-165
  /// @return `true` if the contract implements `interfaceID` and
  function supportsInterface(bytes4 interfaceID) public override(ERC165, IERC165) virtual pure returns (bool) {
    if (interfaceID == type(IERC1155).interfaceId) {
      return true;
    }
    return super.supportsInterface(interfaceID);
  }
}