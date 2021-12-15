// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @title ERC165 Interface
/// @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
/// @author Modified from 0xsequence (https://github.com/0xsequence/erc-1155)
interface IERC165 {
    /// @notice Exposes function for querying interface implementation
    /// @dev Interface identification specified in ERC-165.
    /// @dev Uses less than 30,000 gas.
    /// @param _interfaceId The interface identifier, as specified in ERC-165
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}