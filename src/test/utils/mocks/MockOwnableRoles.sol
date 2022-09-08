// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OwnableRoles} from "../../../src/auth/OwnableRoles.sol";

contract MockOwnableRoles is OwnableRoles {
    bool public flag;

    constructor() {
        _initializeOwner(msg.sender);
    }

    function initializeOwnerDirect(address newOwner, uint256 brutalizer) public {
        assembly {
            newOwner := or(shl(160, brutalizer), newOwner)
        }
        _initializeOwner(newOwner);
    }

    function setOwnerDirect(address newOwner, uint256 brutalizer) public {
        assembly {
            newOwner := or(shl(160, brutalizer), newOwner)
        }
        _setOwner(newOwner);
    }

    function grantRoles(
        address user,
        uint256 brutalizer,
        uint256 roles
    ) public {
        assembly {
            user := or(shl(160, brutalizer), user)
        }
        grantRoles(user, roles);
    }

    function revokeRoles(
        address user,
        uint256 brutalizer,
        uint256 roles
    ) public {
        assembly {
            user := or(shl(160, brutalizer), user)
        }
        revokeRoles(user, roles);
    }

    function hasAnyRoleWithCheck(address user, uint256 roles) public view virtual returns (bool result) {
        result = hasAnyRole(user, roles);
        bool resultIsOneOrZero;
        assembly {
            resultIsOneOrZero := lt(result, 2)
        }
        if (!resultIsOneOrZero) result = !result;
    }

    function updateFlagWithOnlyOwner() public onlyOwner {
        flag = true;
    }

    function updateFlagWithOnlyRoles(uint256 roles) public onlyRoles(roles) {
        flag = true;
    }

    function updateFlagWithOnlyOwnerOrRoles(uint256 roles) public onlyOwnerOrRoles(roles) {
        flag = true;
    }

    function updateFlagWithOnlyRolesOrOwner(uint256 roles) public onlyRolesOrOwner(roles) {
        flag = true;
    }
}
