// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC165 implementation
/// @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
abstract contract ERC165 {

  /// @dev bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

  mapping(bytes4 => bool) private _supportedInterfaces;

  constructor () internal {
      _registerInterface(_INTERFACE_ID_ERC165);
  }

  function supportsInterface(bytes4 interfaceID) virtual public pure returns (bool) {
    return _supportedInterfaces[interfaceId];
  }

  function _registerInterface(bytes4 interfaceId) internal virtual {
    require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
    _supportedInterfaces[interfaceId] = true;
  }
}