// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Trust} from "../auth/Trust.sol";

contract TrustTest is DSTestPlus {
    Trust trust;

    function setUp() public {
        trust = new Trust(address(this));

        trust.setIsTrusted(address(this), false);
    }

    function proveFailTrustNotTrusted(address usr) public {
        trust.setIsTrusted(usr, true);
    }

    function proveFailDistrustNotTrusted(address usr) public {
        trust.setIsTrusted(usr, false);
    }

    function proveTrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));

        assertTrue(!trust.isTrusted(usr));
        trust.setIsTrusted(usr, true);
        assertTrue(trust.isTrusted(usr));
    }

    function proveDistrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));
        forceTrust(usr);

        assertTrue(trust.isTrusted(usr));
        trust.setIsTrusted(usr, false);
        assertTrue(!trust.isTrusted(usr));
    }

    function forceTrust(address usr) internal {
        hevm.store(address(trust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
