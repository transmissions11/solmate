// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.4.23;

import "./DSAuth.sol";

/// @notice A DSAuthority for up to 256 roles.
contract DSRoles is DSAuth, DSAuthority {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRootUpdated(address indexed who, bool enabled);

    event UserRoleUpdated(address indexed who, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed code, bytes4 indexed sig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed code, bytes4 indexed sig, bool enabled);

    /*///////////////////////////////////////////////////////////////
                                  ROLES
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) internal rootUsers;
    mapping(address => bytes32) internal userRoles;
    mapping(address => mapping(bytes4 => bytes32)) internal roleCapabilities;
    mapping(address => mapping(bytes4 => bool)) internal publicCapabilities;

    /*///////////////////////////////////////////////////////////////
                        USER ROLE GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function isUserRoot(address who) public view returns (bool) {
        return rootUsers[who];
    }

    function getUserRoles(address who) public view returns (bytes32) {
        return userRoles[who];
    }

    function getRoleCapabilities(address code, bytes4 sig) public view returns (bytes32) {
        return roleCapabilities[code][sig];
    }

    function isCapabilityPublic(address code, bytes4 sig) public view returns (bool) {
        return publicCapabilities[code][sig];
    }

    function doesUserHaveRole(address who, uint8 role) external view returns (bool) {
        bytes32 roles = getUserRoles(who);
        bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));
        return bytes32(0) != roles & shifted;
    }

    function canCall(
        address caller,
        address code,
        bytes4 sig
    ) public view virtual override returns (bool) {
        if (isCapabilityPublic(code, sig) || isUserRoot(caller)) {
            return true;
        } else {
            bytes32 has_roles = getUserRoles(caller);
            bytes32 needs_one_of = getRoleCapabilities(code, sig);
            return bytes32(0) != has_roles & needs_one_of;
        }
    }

    /*///////////////////////////////////////////////////////////////
                      USER/ROLE MODIFIER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setRootUser(address who, bool enabled) external auth {
        rootUsers[who] = enabled;

        emit UserRootUpdated(who, enabled);
    }

    function setUserRole(
        address who,
        uint8 role,
        bool enabled
    ) public auth {
        bytes32 last_roles = userRoles[who];
        bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));
        if (enabled) {
            userRoles[who] = last_roles | shifted;
        } else {
            userRoles[who] = last_roles & BITNOT(shifted);
        }

        emit UserRoleUpdated(who, role, enabled);
    }

    function setPublicCapability(
        address code,
        bytes4 sig,
        bool enabled
    ) public auth {
        publicCapabilities[code][sig] = enabled;

        emit PublicCapabilityUpdated(code, sig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address code,
        bytes4 sig,
        bool enabled
    ) public auth {
        bytes32 last_roles = roleCapabilities[code][sig];
        bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));
        if (enabled) {
            roleCapabilities[code][sig] = last_roles | shifted;
        } else {
            roleCapabilities[code][sig] = last_roles & BITNOT(shifted);
        }

        emit RoleCapabilityUpdated(role, code, sig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                               INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

    function BITNOT(bytes32 input) internal pure returns (bytes32 output) {
        return (input ^ bytes32(uint256(int256(-1))));
    }
}
