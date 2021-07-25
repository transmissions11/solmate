// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {RequiresAuth} from "./utils/RequiresAuth.sol";

import {TrustAuthority} from "../auth/authorities/TrustAuthority.sol";

contract TrustAuthorityTest is DSTestPlus {
    TrustAuthority trust;
    RequiresAuth requiresAuth;

    function setUp() public {
        trust = new TrustAuthority();
        requiresAuth = new RequiresAuth();

        requiresAuth.setAuthority(trust);

        requiresAuth.setOwner(address(0));
        trust.setIsTrusted(self, false);
    }

    function testSanityChecks() public {
        assertFalse(trust.isTrusted(self));
        assertFalse(trust.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
        try requiresAuth.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function testUpdateTrust() public {
        forceTrust(self);
        assertTrue(trust.isTrusted(self));
        assertTrue(trust.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
        requiresAuth.updateFlag();

        trust.setIsTrusted(self, false);
        assertFalse(trust.isTrusted(self));
        assertFalse(trust.canCall(self, address(requiresAuth), RequiresAuth.updateFlag.selector));
        try requiresAuth.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function forceTrust(address usr) internal {
        hevm.store(address(trust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
