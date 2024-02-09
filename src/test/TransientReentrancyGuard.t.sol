// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {TransientReentrancyGuard} from "../utils/TransientReentrancyGuard.sol";

contract RiskyContract is TransientReentrancyGuard {
    uint256 public enterTimes;

    function unprotectedCall() public {
        enterTimes++;

        if (enterTimes > 1) return;

        this.protectedCall();
    }

    function protectedCall() public nonReentrant {
        enterTimes++;

        if (enterTimes > 1) return;

        this.protectedCall();
    }

    function overprotectedCall() public nonReentrant {}
}

contract TransientReentrancyGuardTest is DSTestPlus {
    RiskyContract riskyContract;

    function setUp() public {
        riskyContract = new RiskyContract();
    }

    function testFailUnprotectedCall() public {
        riskyContract.unprotectedCall();

        assertEq(riskyContract.enterTimes(), 1);
    }

    function testProtectedCall() public {
        try riskyContract.protectedCall() {
            fail("Reentrancy Guard Failed To Stop Attacker");
        } catch {}
    }

    function testNoReentrancy() public {
        riskyContract.overprotectedCall();
    }
}
