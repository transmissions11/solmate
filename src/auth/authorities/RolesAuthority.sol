// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

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

    mapping(address => bool) public isUserRoot;

    mapping(address => bytes32) public getUserRoles;

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            return bytes32(0) != getUserRoles[user] & shifted;
        }
    }

    /*///////////////////////////////////////////////////////////////
                        ROLE CAPABILITY STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(bytes4 => bytes32)) public getRoleCapabilities;

    mapping(address => mapping(bytes4 => bool)) public isCapabilityPublic;

    function doesRoleHaveCapability(
        uint8 role,
        address target,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            return bytes32(0) != getRoleCapabilities[target][functionSig] & shifted;
        }
    }

    /*///////////////////////////////////////////////////////////////
                          AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        if (isCapabilityPublic[target][functionSig]) return true;

        return bytes32(0) != getUserRoles[user] & getRoleCapabilities[target][functionSig] || isUserRoot[user];
    }

    /*///////////////////////////////////////////////////////////////
                  ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        isCapabilityPublic[target][functionSig] = enabled;

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        bytes32 lastCapabilities = getRoleCapabilities[target][functionSig];

        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            getRoleCapabilities[target][functionSig] = enabled
                ? lastCapabilities | shifted
                : lastCapabilities & ~shifted;
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
        bytes32 lastRoles = getUserRoles[user];

        unchecked {
            bytes32 shifted = bytes32(uint256(uint256(2)**uint256(role)));

            getUserRoles[user] = enabled ? lastRoles | shifted : lastRoles & ~shifted;
        }

        emit UserRoleUpdated(user, role, enabled);
    }

    function setRootUser(address user, bool enabled) public virtual requiresAuth {
        isUserRoot[user] = enabled;

        emit UserRootUpdated(user, enabled);
    }
}
