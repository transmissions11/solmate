// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author SolDAO (https://github.com/Sol-DAO/solmate/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    error Reentrancy();
    
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        if (locked == 2) revert Reentrancy(); 

        locked = 2;

        _;

        locked = 1;
    }
}
