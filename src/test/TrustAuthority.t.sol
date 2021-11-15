// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockAuthChild} from "./utils/mocks/MockAuthChild.sol";

import {TrustAuthority} from "../auth/authorities/TrustAuthority.sol";

contract TrustAuthorityTest is DSTestPlus {
    TrustAuthority trust;
    MockAuthChild mockAuthChild;

    function setUp() public {
        trust = new TrustAuthority(address(this));
        mockAuthChild = new MockAuthChild();

        mockAuthChild.setAuthority(trust);
        mockAuthChild.setOwner(DEAD_ADDRESS);

        trust.setIsTrusted(address(this), false);
    }

    function invariantOwner() public {
        assertEq(mockAuthChild.owner(), DEAD_ADDRESS);
    }

    function invariantAuthority() public {
        assertEq(address(mockAuthChild.authority()), address(trust));
    }

    function testSanityChecks() public {
        assertFalse(trust.isTrusted(address(this)));
        assertFalse(trust.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));
        try mockAuthChild.updateFlag() {
            fail("Trust Authority Let Attacker Update Flag");
        } catch {}
    }

    function testUpdateTrust() public {
        forceTrust(address(this));
        assertTrue(trust.isTrusted(address(this)));
        assertTrue(trust.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));
        mockAuthChild.updateFlag();

        trust.setIsTrusted(address(this), false);
        assertFalse(trust.isTrusted(address(this)));
        assertFalse(trust.canCall(address(this), address(mockAuthChild), MockAuthChild.updateFlag.selector));
        try mockAuthChild.updateFlag() {
            fail("Trust Authority Allowed Attacker To Update Flag");
        } catch {}
    }

    function forceTrust(address usr) internal {
        hevm.store(address(trust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
