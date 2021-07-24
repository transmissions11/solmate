// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Optimized reentrancy prevention mixin.
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private reentrancyStatus = NOT_ENTERED;

    modifier nonReentrant() {
        require(reentrancyStatus != ENTERED, "REENTRANCY");

        reentrancyStatus = ENTERED;

        _;

        reentrancyStatus = NOT_ENTERED;
    }
}
