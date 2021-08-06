// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {RequiresAuth} from "./utils/RequiresAuth.sol";

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
    RequiresAuth requiresAuth;

    function setUp() public {
        requiresAuth = new RequiresAuth();
    }

    function invariantOwner() public {
        assertEq(requiresAuth.owner(), self);
    }

    function invariantAuthority() public {
        assertEq(address(requiresAuth.authority()), address(0));
    }

    function testFailNonOwner1() public {
        requiresAuth.setOwner(address(0));
        requiresAuth.updateFlag();
    }

    function testFailNonOwner2() public {
        requiresAuth.setOwner(address(0));
        requiresAuth.setOwner(address(0));
    }

    function testFailRejectingAuthority1() public {
        requiresAuth.setAuthority(Authority(address(new BooleanAuthority(false))));
        requiresAuth.setOwner(address(0));
        requiresAuth.updateFlag();
    }

    function testFailRejectingAuthority2() public {
        requiresAuth.setAuthority(Authority(address(new BooleanAuthority(false))));
        requiresAuth.setOwner(address(0));
        requiresAuth.setOwner(address(0));
    }

    function testAcceptingOwner() public {
        requiresAuth.setAuthority(Authority(address(new BooleanAuthority(true))));
        requiresAuth.setOwner(address(0));
        requiresAuth.updateFlag();
    }
}
