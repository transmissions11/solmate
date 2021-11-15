// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockAuthChild} from "./utils/mocks/MockAuthChild.sol";

import {Auth, Authority} from "../auth/Auth.sol";

contract BooleanAuthority is Authority {
    bool yes;

    constructor(bool _yes) {
        yes = _yes;
    }

    function canCall(
        address,
        address,
        bytes4
    ) public view override returns (bool) {
        return yes;
    }
}

contract AuthTest is DSTestPlus {
    MockAuthChild mockAuthChild;

    function setUp() public {
        mockAuthChild = new MockAuthChild();
    }

    function invariantOwner() public {
        assertEq(mockAuthChild.owner(), address(this));
    }

    function invariantAuthority() public {
        assertEq(address(mockAuthChild.authority()), address(0));
    }

    function testFailNonOwner1() public {
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }

    function testFailNonOwner2() public {
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setOwner(address(0));
    }

    function testFailRejectingAuthority1() public {
        mockAuthChild.setAuthority(Authority(address(new BooleanAuthority(false))));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }

    function testFailRejectingAuthority2() public {
        mockAuthChild.setAuthority(Authority(address(new BooleanAuthority(false))));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setOwner(address(0));
    }

    function testAcceptingOwner() public {
        mockAuthChild.setAuthority(Authority(address(new BooleanAuthority(true))));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }
}
