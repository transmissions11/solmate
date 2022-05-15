// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized pausable functionality for smart contracts.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/Pausable.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol)
abstract contract Pausable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event PauseToggled(address indexed toggler, bool isPaused);

    /*//////////////////////////////////////////////////////////////
                            PAUSABLE STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private _paused = 1;

    modifier whenNotPaused() {
        require(_paused == 1, "PAUSED");

        _;
    }

    modifier whenPaused() {
        require(_paused == 2, "NOT_PAUSED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                             PAUSABLE LOGIC
    //////////////////////////////////////////////////////////////*/

    function isPaused() public view virtual returns (bool) {
        return _paused == 2;
    }

    function togglePause(bool shouldPause) internal virtual {
        uint256 toPause = (shouldPause == false ? 1 : 2);
        require(toPause != _paused, "SAME_TOGGLE");

        _paused = toPause;
        emit PauseToggled(msg.sender, shouldPause);
    }
}
