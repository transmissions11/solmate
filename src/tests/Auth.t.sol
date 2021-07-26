// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import "ds-test/test.sol";

import {Auth, Authority} from "../auth/Auth.sol";

contract FakeVault is Auth {
    function access() public view requiresAuth {}
}

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

contract AuthTest is DSTest {
    FakeVault vault;

    function setUp() public {
        vault = new FakeVault();
    }

    function testFailNonOwner1() public {
        vault.setOwner(address(0));
        vault.access();
    }

    function testFailNonOwner2() public {
        vault.setOwner(address(0));
        vault.setOwner(address(0));
    }

    function testFailRejectingAuthority1() public {
        vault.setAuthority(Authority(address(new BooleanAuthority(false))));
        vault.setOwner(address(0));
        vault.access();
    }

    function testFailRejectingAuthority2() public {
        vault.setAuthority(Authority(address(new BooleanAuthority(false))));
        vault.setOwner(address(0));
        vault.setOwner(address(0));
    }

    function testAcceptingOwner() public logs_gas {
        vault.setAuthority(Authority(address(new BooleanAuthority(true))));
        vault.setOwner(address(0));
        vault.access();
    }
}
