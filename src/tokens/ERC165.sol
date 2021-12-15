// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC165 implementation
/// @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC165 {
  function supportsInterface(bytes4 interfaceID) virtual override public pure returns (bool) {
    return interfaceID == this.supportsInterface.selector;
  }
}