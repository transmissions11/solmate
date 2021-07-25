// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {Auth, Authority} from "../Auth.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @author Modified from DappHub (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is Auth, Authority {
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
            bytes32 hasRoles = getUserRoles(caller);
            bytes32 needsOneOf = getRoleCapabilities(code, sig);
            return bytes32(0) != hasRoles & needsOneOf;
        }
    }

    /*///////////////////////////////////////////////////////////////
                       USER/ROLE SETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setRootUser(address who, bool enabled) external requiresAuth {
        rootUsers[who] = enabled;

        emit UserRootUpdated(who, enabled);
    }

    function setUserRole(
        address who,
        uint8 role,
        bool enabled
    ) public requiresAuth {
        bytes32 lastRoles = userRoles[who];
        bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));
        if (enabled) {
            userRoles[who] = lastRoles | shifted;
        } else {
            userRoles[who] = lastRoles & BITNOT(shifted);
        }

        emit UserRoleUpdated(who, role, enabled);
    }

    function setPublicCapability(
        address code,
        bytes4 sig,
        bool enabled
    ) public requiresAuth {
        publicCapabilities[code][sig] = enabled;

        emit PublicCapabilityUpdated(code, sig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address code,
        bytes4 sig,
        bool enabled
    ) public requiresAuth {
        bytes32 lastRoles = roleCapabilities[code][sig];
        bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));
        if (enabled) {
            roleCapabilities[code][sig] = lastRoles | shifted;
        } else {
            roleCapabilities[code][sig] = lastRoles & BITNOT(shifted);
        }

        emit RoleCapabilityUpdated(role, code, sig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                            INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

    function BITNOT(bytes32 input) internal pure returns (bytes32 output) {
        return (input ^ bytes32(type(uint256).max));
    }
}
