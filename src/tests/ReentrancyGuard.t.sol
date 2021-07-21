// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

import "ds-test/test.sol";
import "../utils/ReentrancyGuard.sol";

contract ReentrancyAttacker {
    function thisWillReenterProtectedCall() external {
        RiskyContract(msg.sender).protectedCall(ReentrancyAttacker(address(this)));
    }

    function thisCallWillReenterUnprotectedCall() external {
        RiskyContract(msg.sender).unprotectedCall(ReentrancyAttacker(address(this)));
    }
}

contract RiskyContract is ReentrancyGuard {
    uint256 public enterTimes;

    function unprotectedCall(ReentrancyAttacker attacker) public {
        enterTimes++;

        if (enterTimes > 1) {
            return;
        }

        attacker.thisCallWillReenterUnprotectedCall();
    }

    function protectedCall(ReentrancyAttacker attacker) public nonReentrant {
        enterTimes++;

        if (enterTimes > 1) {
            return;
        }

        attacker.thisWillReenterProtectedCall();
    }
}

contract ReentrancyGuardTest is DSTest {
    RiskyContract riskyContract;
    ReentrancyAttacker reentrancyAttacker;

    function setUp() public {
        riskyContract = new RiskyContract();
        reentrancyAttacker = new ReentrancyAttacker();
    }

    function testFailUnprotectedCall() public {
        riskyContract.unprotectedCall(reentrancyAttacker);

        assertEq(riskyContract.enterTimes(), 1);
    }

    function testProtectedCall() public {
        try riskyContract.protectedCall(reentrancyAttacker) {
            emit log("Reentrancy Guard Failed To Stop Attacker");
            fail();
        } catch {}
    }
}
