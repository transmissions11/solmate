// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {DSTest} from "ds-test/test.sol";

import {Hevm} from "./utils/Hevm.sol";
import {Trust} from "../auth/Trust.sol";

contract TrustTest is DSTest {
    Hevm hevm = Hevm(HEVM_ADDRESS);

    Trust trust;

    function setUp() public {
        trust = new Trust();
    }

    function testFailTrustNotTrusted(address usr) public {
        if (trust.isTrusted(address(this))) return;
        trust.trust(usr);
    }

    function testTrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));

        assertTrue(!trust.isTrusted(usr));
        trust.trust(usr);
        assertTrue(trust.isTrusted(usr));
    }

    function testFailDistrustNotTrusted(address usr) public {
        if (trust.isTrusted(address(this))) return;
        trust.distrust(usr);
    }

    function testDistrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));
        forceTrust(usr);

        assertTrue(trust.isTrusted(usr));
        trust.distrust(usr);
        assertTrue(!trust.isTrusted(usr));
    }

    function forceTrust(address usr) internal {
        hevm.store(address(trust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
