// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {RequiresTrust} from "./utils/RequiresTrust.sol";

contract TrustTest is DSTestPlus {
    RequiresTrust requiresTrust;

    function setUp() public {
        requiresTrust = new RequiresTrust();

        requiresTrust.setIsTrusted(address(this), false);
    }

    function proveFailTrustNotTrusted(address usr) public {
        requiresTrust.setIsTrusted(usr, true);
    }

    function proveFailDistrustNotTrusted(address usr) public {
        requiresTrust.setIsTrusted(usr, false);
    }

    function proveTrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));

        assertTrue(!requiresTrust.isTrusted(usr));
        requiresTrust.setIsTrusted(usr, true);
        assertTrue(requiresTrust.isTrusted(usr));
    }

    function proveDistrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));
        forceTrust(usr);

        assertTrue(requiresTrust.isTrusted(usr));
        requiresTrust.setIsTrusted(usr, false);
        assertTrue(!requiresTrust.isTrusted(usr));
    }

    function forceTrust(address usr) internal {
        hevm.store(address(requiresTrust), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
