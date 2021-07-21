// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Modified from DappHub (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event AuthorityUpdated(Authority indexed authority);

    event OwnerUpdated(address indexed owner);

    /*///////////////////////////////////////////////////////////////
                       OWNER AND AUTHORITY STORAGE
    //////////////////////////////////////////////////////////////*/

    Authority public authority;

    address public owner;

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                  OWNER AND AUTHORITY SETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setOwner(address owner_) external requiresAuth {
        owner = owner_;
        emit OwnerUpdated(owner);
    }

    function setAuthority(Authority authority_) external requiresAuth {
        authority = authority_;
        emit AuthorityUpdated(authority);
    }

    /*///////////////////////////////////////////////////////////////
                        AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == Authority(address(0))) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
interface Authority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) external view returns (bool);
}
