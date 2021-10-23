// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockTrustChild} from "./utils/mocks/MockTrustChild.sol";

contract TrustTest is DSTestPlus {
    MockTrustChild mockTrustChild;

    function setUp() public {
        mockTrustChild = new MockTrustChild();

        mockTrustChild.setIsTrusted(address(this), false);
    }

    function proveFailTrustNotTrusted(address usr) public {
        mockTrustChild.setIsTrusted(usr, true);
    }

    function proveFailDistrustNotTrusted(address usr) public {
        mockTrustChild.setIsTrusted(usr, false);
    }

    function proveTrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));

        assertTrue(!mockTrustChild.isTrusted(usr));
        mockTrustChild.setIsTrusted(usr, true);
        assertTrue(mockTrustChild.isTrusted(usr));
    }

    function proveDistrust(address usr) public {
        if (usr == address(this)) return;
        forceTrust(address(this));
        forceTrust(usr);

        assertTrue(mockTrustChild.isTrusted(usr));
        mockTrustChild.setIsTrusted(usr, false);
        assertTrue(!mockTrustChild.isTrusted(usr));
    }

    function forceTrust(address usr) internal {
        hevm.store(address(mockTrustChild), keccak256(abi.encode(usr, uint256(0))), bytes32(uint256(1)));
    }
}
