// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
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

    function setOwner(address newOwner) external requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(owner);
    }

    function setAuthority(Authority newAuthority) external requiresAuth {
        authority = newAuthority;

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
        }

        if (src == owner) {
            return true;
        }

        Authority _authority = authority;

        if (_authority == Authority(address(0))) {
            return false;
        }

        return _authority.canCall(src, address(this), sig);
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
