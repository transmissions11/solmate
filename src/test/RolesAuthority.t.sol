// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockAuthChild} from "./utils/mocks/MockAuthChild.sol";

import {Auth, Authority} from "../auth/Auth.sol";
import {RolesAuthority} from "../auth/authorities/RolesAuthority.sol";

contract RolesAuthorityTest is DSTestPlus {
    RolesAuthority roles;
    MockAuthChild mockAuthChild;

    function setUp() public {
        roles = new RolesAuthority(address(this), Authority(address(0)));
        mockAuthChild = new MockAuthChild();

        mockAuthChild.setAuthority(roles);
        mockAuthChild.setOwner(DEAD_ADDRESS);
    }

    function invariantOwner() public {
        assertEq(roles.owner(), address(this));
        assertEq(mockAuthChild.owner(), DEAD_ADDRESS);
    }

    function invariantAuthority() public {
        assertEq(address(roles.authority()), address(0));
        assertEq(address(mockAuthChild.authority()), address(roles));
    }

    function testSanityChecks() public {
        assertEq(roles.getUserRoles(address(this)), bytes32(0));
        assertFalse(roles.isUserRoot(address(this)));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        try mockAuthChild.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function testBasics() public {
        uint8 rootRole = 0;
        uint8 adminRole = 1;
        uint8 modRole = 2;
        uint8 userRole = 3;

        roles.setUserRole(address(this), rootRole, true);
        roles.setUserRole(address(this), adminRole, true);

        assertEq32(
            0x0000000000000000000000000000000000000000000000000000000000000003,
            roles.getUserRoles(address(this))
        );

        roles.setRoleCapability(adminRole, address(mockAuthChild), MockAuthChild.updateFlag.selector, true);
        assertTrue(roles.doesRoleHaveCapability(adminRole, address(mockAuthChild), MockAuthChild.updateFlag.selector));
        assertTrue(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        mockAuthChild.updateFlag();

        roles.setRoleCapability(adminRole, address(mockAuthChild), MockAuthChild.updateFlag.selector, false);
        assertFalse(roles.doesRoleHaveCapability(adminRole, address(mockAuthChild), MockAuthChild.updateFlag.selector));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        assertTrue(roles.doesUserHaveRole(address(this), rootRole));
        assertTrue(roles.doesUserHaveRole(address(this), adminRole));

        assertFalse(roles.doesUserHaveRole(address(this), modRole));
        assertFalse(roles.doesUserHaveRole(address(this), userRole));
    }

    function testRoot() public {
        assertFalse(roles.isUserRoot(address(this)));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        roles.setRootUser(address(this), true);
        assertTrue(roles.isUserRoot(address(this)));
        assertTrue(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        roles.setRootUser(address(this), false);
        assertFalse(roles.isUserRoot(address(this)));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));
    }

    function testPublicCapabilities() public {
        assertFalse(roles.isCapabilityPublic(address(mockAuthChild), MockAuthChild.updateFlag.selector));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        roles.setPublicCapability(address(mockAuthChild), MockAuthChild.updateFlag.selector, true);
        assertTrue(roles.isCapabilityPublic(address(mockAuthChild), MockAuthChild.updateFlag.selector));
        assertTrue(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));

        roles.setPublicCapability(address(mockAuthChild), MockAuthChild.updateFlag.selector, false);
        assertFalse(roles.isCapabilityPublic(address(mockAuthChild), MockAuthChild.updateFlag.selector));
        assertFalse(roles.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));
    }
}
