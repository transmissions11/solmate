// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/// @notice Gas optimized reentrancy protection for smart contracts. Leverages Cancun transient storage.
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

            // Any non-zero value would work, but
            // ADDRESS is cheap and certainly not 0.
            // Wastes a bit of gas doing this before
            // require in the revert path, but we're
            // only optimizing for the happy path here.
            tstore(REENTRANCY_GUARD_SLOT, address())
        }

        require(noReentrancy, "REENTRANCY");

        _;

        /// @solidity memory-safe-assembly
        assembly {
            // Need to set back to zero, as transient
            // storage is only cleared at the end of the
            // tx, not the end of the outermost call frame.
            tstore(REENTRANCY_GUARD_SLOT, 0)
        }
    }
}
