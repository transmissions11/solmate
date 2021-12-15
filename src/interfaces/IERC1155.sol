// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IERC165} from './IERC165.sol';

/// @title ERC1155 Interface
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
interface IERC1155 is IERC165 {

  /*///////////////////////////////////////////////////////////////
                                EVENTS
  //////////////////////////////////////////////////////////////*/

  /// @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
  /// @dev Operator MUST be msg.sender
  /// @dev When minting/creating tokens, the `_from` field MUST be set to `0x0`
  /// @dev When burning/destroying tokens, the `_to` field MUST be set to `0x0`
  /// @dev The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
  /// @dev To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  /// @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
  /// @dev Operator MUST be msg.sender
  /// @dev When minting/creating tokens, the `_from` field MUST be set to `0x0`
  /// @dev When burning/destroying tokens, the `_to` field MUST be set to `0x0`
  /// @dev The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
  /// @dev To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  /// @dev MUST emit when an approval is updated
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /*///////////////////////////////////////////////////////////////
                          IERC1155 LOGIC
  //////////////////////////////////////////////////////////////*/

  /// @notice Transfers amount of an _id from the _from address to the _to address specified
  /// @dev MUST emit TransferSingle event on success
  /// @dev Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
  /// @dev MUST throw if `_to` is the zero address
  /// @dev MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
  /// @dev MUST throw on any other error
  /// @dev When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
  /// @param _from    Source address
  /// @param _to      Target address
  /// @param _id      ID of the token type
  /// @param _amount  Transfered amount
  /// @param _data    Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

  /// @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
  /// @dev MUST emit TransferBatch event on success
  /// @dev Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
  ///  @devMUST throw if `_to` is the zero address
  /// @dev MUST throw if length of `_ids` is not the same as length of `_amounts`
  /// @dev MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
  /// @dev MUST throw on any other error
  /// @dev When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
  /// @dev Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
  /// @param _from     Source addresses
  /// @param _to       Target addresses
  /// @param _ids      IDs of each token type
  /// @param _amounts  Transfer amounts per token type
  /// @param _data     Additional data with no specified format, sent in call to `_to`
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  /// @notice Get the balance of an account's Tokens
  /// @param _owner  The address of the token holder
  /// @param _id     ID of the Token
  /// @return        The _owner's balance of the Token type requested
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

  /// @notice Get the balance of multiple account/token pairs
  /// @param _owners The addresses of the token holders
  /// @param _ids    ID of the Tokens
 /// @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

  /// @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
  /// @dev MUST emit the ApprovalForAll event on success
  /// @param _operator  Address to add to the set of authorized operators
  /// @param _approved  True if the operator is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external;

  /// @notice Queries the approval status of an operator for a given owner
  /// @param _owner     The owner of the Tokens
  /// @param _operator  Address of authorized operator
  /// @return isOperator True if the operator is approved, false if not
  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);
}