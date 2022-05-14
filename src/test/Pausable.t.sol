// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockPausable} from "./utils/mocks/MockPausable.sol";

contract PausableTest is DSTestPlus {
    event PauseToggled(address indexed toggler, bool isPaused);
    MockPausable mockpausable;

    function setUp() public {
        mockpausable = new MockPausable();
    }

    function testPause() public {
        assertBoolEq(mockpausable.isPaused(), false);
        hevm.expectEmit(true, true, true, true);
        emit PauseToggled(address(this), true);

        mockpausable.pause();
        assertBoolEq(mockpausable.isPaused(), true);
    }

    function testUnPause() public {
        assertBoolEq(mockpausable.isPaused(), false);
        hevm.expectEmit(true, true, true, true);
        emit PauseToggled(address(this), true);

        mockpausable.pause();

        assertBoolEq(mockpausable.isPaused(), true);
        hevm.expectEmit(true, true, true, true);
        emit PauseToggled(address(this), false);

        mockpausable.unpause();
        assertBoolEq(mockpausable.isPaused(), false);
    }

    function testSameToggleShouldFail() public {
        hevm.expectRevert("SAME_TOGGLE");
        mockpausable.unpause();
        mockpausable.pause();
        hevm.expectRevert("SAME_TOGGLE");
        mockpausable.pause();
    }

    function testNormalCall() public {
        assertEq(mockpausable.normalCallCount(), 0);
        mockpausable.normalCall();
        assertEq(mockpausable.normalCallCount(), 1);
    }

    function testNormalCallShouldFail() public {
        assertEq(mockpausable.normalCallCount(), 0);
        mockpausable.pause();
        hevm.expectRevert("PAUSED");

        mockpausable.normalCall();
        assertEq(mockpausable.normalCallCount(), 0);
    }

    function testEmergencyCall() public {
        assertBoolEq(mockpausable.emergencyWrite(), false);
        mockpausable.pause();
        mockpausable.emergencyCall();
        assertBoolEq(mockpausable.emergencyWrite(), true);
    }

    function testEmergencyCallShouldFail() public {
        assertBoolEq(mockpausable.emergencyWrite(), false);
        hevm.expectRevert("NOT_PAUSED");

        mockpausable.emergencyCall();
        assertBoolEq(mockpausable.emergencyWrite(), false);
    }
}
