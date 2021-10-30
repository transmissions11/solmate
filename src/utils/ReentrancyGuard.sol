// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Original work by Transmissions11 (https://github.com/transmissions11)
abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        assembly {
            // If reentrancyStatus is 2, revert.
            if eq(sload(reentrancyStatus.slot), 2) {
                revert(0, 0)
            }

            // Set reentrancyStatus to 2.
            sstore(reentrancyStatus.slot, 2)
        }

        _; // Execute the function body.

        assembly {
            // Set reentrancyStatus to 1 again.
            sstore(reentrancyStatus.slot, 1)
        }
    }
}
