// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.4.23;

import "./DSAuthority.sol";

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
abstract contract DSAuth {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);

    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) external auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) external auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth() {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(address(0))) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}
