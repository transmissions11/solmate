// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author DappHub and TransmissionsDev
abstract contract Auth {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event LogSetAuthority(Authority indexed authority);

    event LogSetOwner(address indexed owner);

    /*///////////////////////////////////////////////////////////////
                       OWNER AND AUTHORITY STORAGE
    //////////////////////////////////////////////////////////////*/

    Authority public authority;

    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                  OWNER AND AUTHORITY SETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setOwner(address owner_) external auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(Authority authority_) external auth {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    /*///////////////////////////////////////////////////////////////
                        AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    modifier auth() {
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
