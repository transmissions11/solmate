// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {RequiresAuth} from "./utils/RequiresAuth.sol";

import {Auth} from "../auth/Auth.sol";
import {RolesAuthority} from "../auth/authorities/RolesAuthority.sol";

contract RolesAuthorityTest is DSTestPlus {
    RolesAuthority roles;
    RequiresAuth requiresAuth;

    function setUp() public {
        roles = new RolesAuthority();
        requiresAuth = new RequiresAuth();

        requiresAuth.setAuthority(roles);
        requiresAuth.setOwner(address(0));
    }

    function testSanityChecks() public {
        assertEq(roles.getUserRoles(self), bytes32(0));
        assertFalse(roles.isUserRoot(self));
        assertFalse(roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        try requiresAuth.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function testBasics() public {
        uint8 rootRole = 0;
        uint8 adminRole = 1;
        uint8 modRole = 2;
        uint8 userRole = 3;

        roles.setUserRole(self, rootRole, true);
        roles.setUserRole(self, adminRole, true);

        assertEq32(0x0000000000000000000000000000000000000000000000000000000000000003, roles.getUserRoles(self));

        roles.setRoleCapability(adminRole, address(requiresAuth), RequiresAuth.updateFlag.selector, true);

        assertTrue(roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
        requiresAuth.updateFlag();

        roles.setRoleCapability(adminRole, address(requiresAuth), RequiresAuth.updateFlag.selector, false);
        assertTrue(!roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        assertTrue(roles.doesUserHaveRole(self, rootRole));
        assertTrue(roles.doesUserHaveRole(self, adminRole));
        assertTrue(!roles.doesUserHaveRole(self, modRole));
        assertTrue(!roles.doesUserHaveRole(self, userRole));
    }

    function testRoot() public {
        assertTrue(!roles.isUserRoot(self));
        assertTrue(!roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setRootUser(self, true);
        assertTrue(roles.isUserRoot(self));
        assertTrue(roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setRootUser(self, false);
        assertTrue(!roles.isUserRoot(self));
        assertTrue(!roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
    }

    function testPublicCapabilities() public {
        assertTrue(!roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(!roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setPublicCapability(address(requiresAuth), RequiresAuth.updateFlag.selector, true);
        assertTrue(roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setPublicCapability(address(requiresAuth), RequiresAuth.updateFlag.selector, false);
        assertTrue(!roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(!roles.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
    }
}
