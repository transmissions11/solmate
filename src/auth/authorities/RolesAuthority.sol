// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {Auth, Authority} from "../Auth.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is Auth, Authority {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRootUpdated(address indexed user, bool enabled);

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

    /*///////////////////////////////////////////////////////////////
                             USER ROLE STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) internal rootUsers;

    mapping(address => bytes32) internal userRoles;

    function isUserRoot(address user) public view virtual returns (bool) {
        return rootUsers[user];
    }

    function getUserRoles(address user) public view virtual returns (bytes32) {
        return userRoles[user];
    }

    /*///////////////////////////////////////////////////////////////
                        ROLE CAPABILITY STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(bytes4 => bytes32)) internal roleCapabilities;

    mapping(address => mapping(bytes4 => bool)) internal publicCapabilities;

    function getRoleCapabilities(address target, bytes4 functionSig) public view virtual returns (bytes32) {
        return roleCapabilities[target][functionSig];
    }

    function isCapabilityPublic(address target, bytes4 functionSig) public view virtual returns (bool) {
        return publicCapabilities[target][functionSig];
    }

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        bytes32 roles = getUserRoles(user);

        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            return bytes32(0) != roles & shifted;
        }
    }

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        if (isCapabilityPublic(target, functionSig) || isUserRoot(user)) {
            return true;
        } else {
            bytes32 hasRoles = getUserRoles(user);
            bytes32 needsOneOf = getRoleCapabilities(target, functionSig);

            return bytes32(0) != hasRoles & needsOneOf;
        }
    }

    /*///////////////////////////////////////////////////////////////
                  ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        publicCapabilities[target][functionSig] = enabled;

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        bytes32 lastRoles = roleCapabilities[target][functionSig];

        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            roleCapabilities[target][functionSig] = enabled ? lastRoles | shifted : lastRoles & ~shifted;
        }

        emit RoleCapabilityUpdated(role, target, functionSig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                      USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) public virtual requiresAuth {
        bytes32 lastRoles = userRoles[user];

        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            userRoles[user] = enabled ? lastRoles | shifted : lastRoles & ~shifted;
        }

        emit UserRoleUpdated(user, role, enabled);
    }

    function setRootUser(address user, bool enabled) public virtual requiresAuth {
        rootUsers[user] = enabled;

        emit UserRootUpdated(user, enabled);
    }
}
