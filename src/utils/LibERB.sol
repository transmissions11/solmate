// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";

// TODO: Should we return the updateNumber from the read funcs?

// TODO: Does a fixed size array save gas vs a dynamic or mapping?

// TODO: Prove conjectures about ERB properties with Forge invariants.

// TODO: Could make this more efficient if we removed availableSlots
// and only allowed grow to be called when index == populatedSlots - 1.

// TODO: Technically don't need an ERBValue struct? Unless people find
// knowing the updateNumber helpful? It also allows touching the array
// without messing up value in grow tho. If we removed I'd like to add
// the "can't read uninitialized" slots rule back to the read functions.
// I think the best thing to do would be to make it a generic param, then
// if users find it useful they can attach update number, or timestamp, etc.

/*//////////////////////////////////////////////////////////////
                               ERB
//////////////////////////////////////////////////////////////*/

/// @notice Low-level library for interacting with an expandable ring buffer.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibERB.sol)
library LibERB {
    struct ERBValue {
        uint224 value;
        uint32 updateNumber;
    }

    // Expected invariants:
    // - availableSlots >= 1
    // - totalUpdates >= populatedSlots
    // - totalUpdates < type(uint32).max
    // - availableSlots >= populatedSlots

    function grow(
        ERBValue[65535] storage self,
        uint16 growBy,
        uint16 availableSlots
    ) internal returns (uint16 newTotalAvailableSlots) {
        // This will overflow if we're trying to grow by too much.
        newTotalAvailableSlots = availableSlots + growBy;

        unchecked {
            for (uint256 i = availableSlots; i < newTotalAvailableSlots; i++)
                // We already implicitly assume we'll never
                // reach type(uint32).max many total updates.
                self[i].updateNumber = type(uint32).max;
        }
    }

    function write(
        ERBValue[65535] storage self,
        uint224 value,
        uint32 totalUpdates,
        uint16 populatedSlots,
        uint16 availableSlots // Note: This MUST be at least 1.
    ) internal returns (uint32 newTotalUpdates, uint16 newPopulatedSlots) {
        unchecked {
            // TODO: hmm ok we also need to make sure we dont exceed available slots
            // TODO: wait why do we even need to do this???
            // TODO: also wait confused about the root cause, why does poulpated slots matter again
            newPopulatedSlots = populatedSlots == 0 ||
                (totalUpdates % populatedSlots == (populatedSlots - 1) && populatedSlots < availableSlots)
                ? populatedSlots + 1
                : populatedSlots;

            newTotalUpdates = totalUpdates + 1; // This will silently overflow if we reach type(uint32).max updates.

            self[totalUpdates % newPopulatedSlots] = ERBValue({value: value, updateNumber: newTotalUpdates});
        }
    }

    function read(
        ERBValue[65535] storage self,
        uint32 totalUpdates,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        // We use unsafeMod so that we use index 0 when populatedSlots is 0.
        return self[FixedPointMathLib.unsafeMod(totalUpdates, populatedSlots)];
    }

    function readOffset(
        ERBValue[65535] storage self,
        uint32 offset,
        uint32 totalUpdates,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        unchecked {
            // We can't read back further than our # of populated slots will allow.
            require(offset <= populatedSlots, "OUT_OF_BOUNDS");

            // We use unsafeMod so that we use index 0 when populatedSlots is 0.
            // We assume the invariant totalUpdates >= populatedSlots is maintained.
            return self[FixedPointMathLib.unsafeMod(totalUpdates - offset, populatedSlots)];
        }
    }

    function readUpdateNumber(
        ERBValue[65535] storage self,
        uint32 updateNumber,
        uint32 totalUpdates,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        // We can't read back further than our # of populated slots will allow.
        // This will safely revert due to underflow if updateNumber > totalUpdates.
        require(totalUpdates - updateNumber <= populatedSlots, "OUT_OF_BOUNDS");

        // Return early if we just wan't the current value. We use
        // unsafeMod so that we use index 0 when populatedSlots is 0.
        return self[FixedPointMathLib.unsafeMod(updateNumber, populatedSlots)];
    }
}

/*//////////////////////////////////////////////////////////////
                            BOXED ERB
//////////////////////////////////////////////////////////////*/

/// @notice High-level library for interacting with a self-managing encapsulated ERB.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibERB.sol)
library LibBoxedERB {
    struct BoxedERB {
        uint32 totalUpdates;
        uint16 populatedSlots;
        uint16 availableSlots;
        LibERB.ERBValue[65535] erb;
    }

    using LibERB for LibERB.ERBValue[65535];

    // This should be called once and only
    // once over the lifetime of the contract,
    // before any calls to write are attempted.
    function init(BoxedERB storage self) internal {
        self.availableSlots = 1;

        // We already implicitly assume we'll never
        // reach type(uint32).max many total updates.
        self.erb[0].updateNumber = type(uint32).max;
    }

    function grow(BoxedERB storage self, uint16 growBy) internal {
        self.availableSlots = self.erb.grow(growBy, self.availableSlots);
    }

    // This should only be called if init has been called before.
    function write(BoxedERB storage self, uint224 value) internal {
        (self.totalUpdates, self.populatedSlots) = self.erb.write(
            value,
            self.totalUpdates,
            self.populatedSlots,
            self.availableSlots
        );
    }

    function read(BoxedERB storage self) internal view returns (LibERB.ERBValue memory) {
        return self.erb.read(self.totalUpdates, self.populatedSlots);
    }

    function readOffset(BoxedERB storage self, uint32 offset) internal view returns (LibERB.ERBValue memory) {
        return self.erb.readOffset(offset, self.totalUpdates, self.populatedSlots);
    }

    function readUpdateNumber(BoxedERB storage self, uint32 updateNumber)
        internal
        view
        returns (LibERB.ERBValue memory)
    {
        return self.erb.readUpdateNumber(updateNumber, self.totalUpdates, self.populatedSlots);
    }
}
