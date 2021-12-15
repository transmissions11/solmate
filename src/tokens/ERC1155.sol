// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IERC1155TokenReceiver} from "../interfaces/IERC1155TokenReceiver.sol";
import {IERC1155} from "../interfaces/IERC1155.sol";
import {ERC165} from "../utils/ERC165.sol";


/// @notice Modern and gas efficient ERC1155 implementation.
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC1155 is IERC1155, ERC165 {

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
                    Public Transfer Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Transfers amount amount of an _id from the _from address to the _to address specified
  /// @param _from    Source address
  /// @param _to      Target address
  /// @param _id      ID of the token type
  /// @param _amount  Transfered amount
  /// @param _data    Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) public override {
    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");
    // require(_amount <= balances[_from][_id]) is not necessary since checked with safemath operations

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
  }

  /// @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
  /// @param _from     Source addresses
  /// @param _to       Target addresses
  /// @param _ids      IDs of each token type
  /// @param _amounts  Transfer amounts per token type
  /// @param _data     Additional data with no specified format, sent in call to `_to`
  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) public override {
    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
  }

  /*///////////////////////////////////////////////////////////////
                    Internal Transfer Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Transfers amount amount of an _id from the _from address to the _to address specified
  /// @param _from    Source address
  /// @param _to      Target address
  /// @param _id      ID of the token type
  /// @param _amount  Transfered amount
  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) internal {
    balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount from
    balances[_to][_id] = balances[_to][_id].add(_amount);     // Add amount to

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  /// @notice Verifies if receiver is contract and if so, calls (_to).onERC1155Received(...)
  /// @param _from     Source address
  /// @param _to       Target address
  /// @param _id       ID of the token type
  /// @param _amount   Transfered amount
  /// @param _gasLimit The gas limit
  /// @param _data     Data to call with
  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data) internal {
    // Check if recipient is contract using inline code length
    if (_to.code.length > 0) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received{gas: _gasLimit}(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, "ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  /// @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
  /// @param _from     Source addresses
  /// @param _to       Target addresses
  /// @param _ids      IDs of each token type
  /// @param _amounts  Transfer amounts per token type
  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts) internal {
    require(_ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

    // Number of transfer to execute
    uint256 nTransfer = _ids.length;

    // Executing all transfers
    for (uint256 i = 0; i < nTransfer; i++) {
      // Update storage balance of previous bin
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
      balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  /// @notice Verifies if receiver is contract and if so, calls (_to).onERC1155BatchReceived(...)
  /// @param _from     Source addresses
  /// @param _to       Target addresses
  /// @param _ids      IDs of each token type
  /// @param _amounts  Transfer amounts per token type
  /// @param _gasLimit The gas limit
  /// @param _data     Data to call with
  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data) internal {
    // Pass data if recipient is contract
    if (_to.code.length > 0) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived{gas: _gasLimit}(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  /*///////////////////////////////////////////////////////////////
                        Operator Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
  /// @param _operator  Address to add to the set of authorized operators
  /// @param _approved  True if the operator is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external override {
    // Update operator status
    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /// @notice Queries the approval status of an operator for a given owner
  /// @param _owner     The owner of the Tokens
  /// @param _operator  Address of authorized operator
  /// @return isOperator True if the operator is approved, false if not
  function isApprovedForAll(address _owner, address _operator) public override view returns (bool isOperator) {
    return operators[_owner][_operator];
  }


  /*///////////////////////////////////////////////////////////////
                        Balance Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Get the balance of an account's Tokens
  /// @param _owner  The address of the token holder
  /// @param _id     ID of the Token
  /// @return The _owner's balance of the Token type requested
  function balanceOf(address _owner, uint256 _id) public override view returns (uint256) {
    return balances[_owner][_id];
  }

  /// @notice Get the balance of multiple account/token pairs
  /// @param _owners The addresses of the token holders
  /// @param _ids    ID of the Tokens
  /// @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) public override view returns (uint256[] memory) {
    require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

    // Variables
    uint256[] memory batchBalances = new uint256[](_owners.length);

    // Iterate over each owner and token ID
    for (uint256 i = 0; i < _owners.length; i++) {
      batchBalances[i] = balances[_owners[i]][_ids[i]];
    }

    return batchBalances;
  }

  /*///////////////////////////////////////////////////////////////
                        ERC165 Functions
  //////////////////////////////////////////////////////////////*/

  /// @notice Query if a contract implements an interface
  /// @param _interfaceID  The interface identifier, as specified in ERC-165
  /// @return `true` if the contract implements `_interfaceID` and
  function supportsInterface(bytes4 _interfaceID) public override(ERC165, IERC165) virtual pure returns (bool) {
    if (_interfaceID == type(IERC1155).interfaceId) {
      return true;
    }
    return super.supportsInterface(_interfaceID);
  }
}