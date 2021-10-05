// SPDX-License-Identifier: AGPL-3.0-only
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
        requiresAuth.setOwner(DEAD_ADDRESS);
    }

    function invariantOwner() public {
        assertEq(roles.owner(), address(this));
        assertEq(requiresAuth.owner(), DEAD_ADDRESS);
    }

    function invariantAuthority() public {
        assertEq(address(roles.authority()), address(0));
        assertEq(address(requiresAuth.authority()), address(roles));
    }

    function testSanityChecks() public {
        assertEq(roles.getUserRoles(address(this)), bytes32(0));
        assertFalse(roles.isUserRoot(address(this)));
        assertFalse(roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        try requiresAuth.updateFlag() {
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

        roles.setRoleCapability(adminRole, address(requiresAuth), RequiresAuth.updateFlag.selector, true);

        assertTrue(roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
        requiresAuth.updateFlag();

        roles.setRoleCapability(adminRole, address(requiresAuth), RequiresAuth.updateFlag.selector, false);
        assertTrue(!roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        assertTrue(roles.doesUserHaveRole(address(this), rootRole));
        assertTrue(roles.doesUserHaveRole(address(this), adminRole));
        assertTrue(!roles.doesUserHaveRole(address(this), modRole));
        assertTrue(!roles.doesUserHaveRole(address(this), userRole));
    }

    function testRoot() public {
        assertTrue(!roles.isUserRoot(address(this)));
        assertTrue(!roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setRootUser(address(this), true);
        assertTrue(roles.isUserRoot(address(this)));
        assertTrue(roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setRootUser(address(this), false);
        assertTrue(!roles.isUserRoot(address(this)));
        assertTrue(!roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
    }

    function testPublicCapabilities() public {
        assertTrue(!roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(!roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setPublicCapability(address(requiresAuth), RequiresAuth.updateFlag.selector, true);
        assertTrue(roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));

        roles.setPublicCapability(address(requiresAuth), RequiresAuth.updateFlag.selector, false);
        assertTrue(!roles.isCapabilityPublic(address(requiresAuth), RequiresAuth.updateFlag.selector));
        assertTrue(!roles.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
    }
}
