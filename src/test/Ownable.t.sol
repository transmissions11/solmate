// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockOwnable} from "./utils/mocks/MockOwnable.sol";

contract AuthTest is DSTestPlus {
    MockOwnable mockOwnable;

    function setUp() public {
        mockOwnable = new MockOwnable();
    }

    function testSetOwnerForOwnable() public {
        mockOwnable.setOwner(address(0xBEEF), true);
        assertEq(mockOwnable.owner(), address(0xBEEF));
    }

    function testSetPendingOwnerForOwnable() public {
        mockOwnable.setOwner(address(0xBEEF), false);
        assertEq(mockOwnable.pendingOwner(), address(0xBEEF));
    }

    function testClaimOwnerForOwnableAsPendingOwner() public {
        mockOwnable.setOwner(address(this), false);
        assertEq(mockOwnable.pendingOwner(), address(this));
        mockOwnable.claimOwner();
        assertEq(mockOwnable.owner(), address(this));
    }

    function testCallFunctionAsOwnableOwner() public {
        mockOwnable.updateFlag();
    }

    function testFailCallFunctionAsNonOwnableOwner() public {
        mockOwnable.setOwner(address(0), true);
        mockOwnable.updateFlag();
    }
}
