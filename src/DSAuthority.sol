// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.4.23;

/// @notice A generic interface for a contract which provides authorization data to a DSAuth instance.
interface DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) external view returns (bool);
}
