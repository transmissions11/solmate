// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

import "ds-test/test.sol";
import "../auth/Auth.sol";

contract FakeVault is Auth {
    function access() public view auth {}
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

    function testFail_non_owner_1() public {
        vault.setOwner(address(0));
        vault.access();
    }

    function testFail_non_owner_2() public {
        vault.setOwner(address(0));
        vault.setOwner(address(0));
    }

    function test_accepting_authority() public {
        vault.setAuthority(Authority(address(new BooleanAuthority(true))));
        vault.setOwner(address(0));
        vault.access();
    }

    function testFail_rejecting_authority_1() public {
        vault.setAuthority(Authority(address(new BooleanAuthority(false))));
        vault.setOwner(address(0));
        vault.access();
    }

    function testFail_rejecting_authority_2() public {
        vault.setAuthority(Authority(address(new BooleanAuthority(false))));
        vault.setOwner(address(0));
        vault.setOwner(address(0));
    }
}
