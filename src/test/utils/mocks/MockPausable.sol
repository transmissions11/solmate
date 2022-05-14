// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {Pausable} from "../../../utils/Pausable.sol";

contract MockPausable is Pausable {
    bool public emergencyWrite = false;
    uint256 public normalCallCount = 0;

    function normalCall() external whenNotPaused {
        normalCallCount++;
    }

    function emergencyCall() external whenPaused {
        emergencyWrite = true;
    }

    function pause() external {
        togglePause(true);
    }

    function unpause() external {
        togglePause(false);
    }
}
