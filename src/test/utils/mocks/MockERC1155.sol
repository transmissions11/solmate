// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC1155} from "../../../tokens/ERC1155.sol";

contract MockERC1155 is ERC1155 {

    constructor(
        string memory _URI
    ) {
      URI = _URI;
    }


    function mint(address to, uint256 id, uint256 amount, bytes memory data) external {
      _mint(to, id, amount, data);
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal {
      balances[to][id] = balances[to][id] + amount;
      emit TransferSingle(msg.sender, address(0x0), to, id, amount);
      _callonERC1155Received(address(0x0), to, id, amount, gasleft(), data);
    }

    function batchMint(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external {
        _batchMint(to, ids, amounts, data);
    }

    function _batchMint(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
      require(ids.length == amounts.length, "INVALID_ARRAYS_LENGTH");

      uint256 nMint = ids.length;
      for (uint256 i = 0; i < nMint; i++) {
        balances[to][ids[i]] = balances[to][ids[i]] + amounts[i];
      }

      emit TransferBatch(msg.sender, address(0x0), to, ids, amounts);
      _callonERC1155BatchReceived(address(0x0), to, ids, amounts, gasleft(), data);
    }

    function burn(address from, uint256 id, uint256 amount) external {
        _burn(from, id, amount);
    }

    function _burn(address from, uint256 id, uint256 amount) internal {
      balances[from][id] = balances[from][id] - amount;
      emit TransferSingle(msg.sender, from, address(0x0), id, amount);
    }

    function batchBurn(address from, uint256[] memory ids, uint256[] memory amounts) external {
        _batchBurn(from, ids, amounts);
    }

    function _batchBurn(address from, uint256[] memory ids, uint256[] memory amounts) internal {
      uint256 nBurn = ids.length;
      require(nBurn == amounts.length, "INVALID_ARRAYS_LENGTH");

      for (uint256 i = 0; i < nBurn; i++) {
        balances[from][ids[i]] = balances[from][ids[i]] - amounts[i];
      }

      emit TransferBatch(msg.sender, from, address(0x0), ids, amounts);
    }
}
