// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        //`require(locked == 1)` works fine in normal conditions. But when deployed via proxy, the storage slot should be manually set to 1, by default it would be 0.
        // Hence, instead of setting the storage, we can simply check whether `locked < 2`.
        require(locked < 2, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
