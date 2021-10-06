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
        requiresAuth.setOwner(DEAD_ADDRESS);

        trust.setIsTrusted(address(this), false);
    }

    function invariantOwner() public {
        assertEq(requiresAuth.owner(), DEAD_ADDRESS);
    }

    function invariantAuthority() public {
        assertEq(address(requiresAuth.authority()), address(trust));
    }

    function testSanityChecks() public {
        assertFalse(trust.isTrusted(address(this)));
        assertFalse(trust.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
        try requiresAuth.updateFlag() {
            fail("Trust Authority Let Attacker Update Flag");
        } catch {}
    }

    function testUpdateTrust() public {
        forceTrust(address(this));
        assertTrue(trust.isTrusted(address(this)));
        assertTrue(trust.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
        requiresAuth.updateFlag();

        trust.setIsTrusted(address(this), false);
        assertFalse(trust.isTrusted(address(this)));
        assertFalse(trust.canCall(address(this), address(requiresAuth), RequiresAuth.updateFlag.selector));
        try requiresAuth.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function forceTrust(address usr) internal {
        hevm.store(address(trust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
