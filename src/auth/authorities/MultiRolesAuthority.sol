// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {Auth, Authority} from "../Auth.sol";

/// @notice Flexible and target agnostic role based Authority that supports up to 256 roles.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/authorities/MultiRolesAuthority.sol)
contract MultiRolesAuthority is Auth, Authority {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, bytes4 indexed functionSig, bool enabled);

    event TargetCustomAuthorityUpdated(address indexed target, Authority indexed authority);

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

    /*///////////////////////////////////////////////////////////////
                       CUSTOM TARGET AUTHORITY STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => Authority) public getTargetCustomAuthority;

    /*///////////////////////////////////////////////////////////////
                             USER ROLE STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bytes32) public getUserRoles;

    function doesUserHaveRole(address user, uint8 role) external view returns (bool) {
        unchecked {
            bytes32 roleMask = bytes32(2**uint256(role));

            return bytes32(0) != getUserRoles[user] & roleMask;
        }
    }

    /*/////i//////////////////////////////////////////////////////////
                        ROLE CAPABILITY STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(bytes4 => bytes32) public getRolesWithCapability;

    mapping(bytes4 => bool) public isCapabilityPublic;

    function doesRoleHaveCapability(uint8 role, bytes4 functionSig) external view virtual returns (bool) {
        unchecked {
            bytes32 roleMask = bytes32(2**uint256(role));

            return bytes32(0) != getRolesWithCapability[functionSig] & roleMask;
        }
    }

    /*///////////////////////////////////////////////////////////////
                          AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view override returns (bool) {
        Authority customAuthority = getTargetCustomAuthority[target];

        if (address(customAuthority) != address(0)) return customAuthority.canCall(user, target, functionSig);

        return
            bytes32(0) != getUserRoles[user] & getRolesWithCapability[functionSig] || isCapabilityPublic[functionSig];
    }

    /*///////////////////////////////////////////////////////////////
               CUSTOM TARGET AUTHORITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setTargetCustomAuthority(address target, Authority customAuthority) external requiresAuth {
        getTargetCustomAuthority[target] = customAuthority;

        emit TargetCustomAuthorityUpdated(target, customAuthority);
    }

    /*///////////////////////////////////////////////////////////////
                  ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setRoleCapability(
        uint8 role,
        bytes4 functionSig,
        bool enabled
    ) external requiresAuth {
        bytes32 lastCapabilities = getRolesWithCapability[functionSig];

        unchecked {
            bytes32 roleMask = bytes32(2**uint256(role));

            getRolesWithCapability[functionSig] = enabled ? lastCapabilities | roleMask : lastCapabilities & ~roleMask;
        }

        emit RoleCapabilityUpdated(role, functionSig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                  PUBLIC CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(bytes4 functionSig, bool enabled) external requiresAuth {
        isCapabilityPublic[functionSig] = enabled;

        emit PublicCapabilityUpdated(functionSig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                      USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) external requiresAuth {
        bytes32 lastRoles = getUserRoles[user];

        unchecked {
            bytes32 roleMask = bytes32(2**uint256(role));

            getUserRoles[user] = enabled ? lastRoles | roleMask : lastRoles & ~roleMask;
        }

        emit UserRoleUpdated(user, role, enabled);
    }
}
