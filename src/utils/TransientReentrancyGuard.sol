// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts. Leverages Cancuntransient storage.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/TransientReentrancyGuard.sol)
/// @author Modified from Soledge (https://github.com/Vectorized/soledge/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract TransientReentrancyGuard {
    /// Warning: Be careful to avoid collisions with this hand picked slot!
    uint256 private constant REENTRANCY_GUARD_SLOT = 0x1FACE81BADDEADBEEF;


    modifier nonReentrant() virtual {
        bool noReentrancy;

        /// @solidity memory-safe-assembly
        assembly {
            noReentrancy := iszero(tload(REENTRANCY_GUARD_SLOT))

            tstore(REENTRANCY_GUARD_SLOT, address())
        }

        require(noReentrancy, "REENTRANCY");

        _;

        /// @solidity memory-safe-assembly
        assembly {
            tstore(REENTRANCY_GUARD_SLOT, 0)
        }
    }
}
