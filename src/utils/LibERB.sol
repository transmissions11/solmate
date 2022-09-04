// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";

// TODO: Should we return the writeNumber from the read funcs?

// TODO: Does a fixed size array save gas vs a dynamic or mapping?

// TODO: Prove conjectures about ERB properties with Forge invariants.

// TODO: Could make this more efficient if we removed availableSlots
// and only allowed grow to be called when index == populatedSlots - 1.

// TODO: Technically don't need an ERBValue struct? Unless people find
// knowing the writeNumber helpful? It also allows touching the array
// without messing up value in grow tho. If we removed I'd like to add
// the "can't read uninitialized" slots rule back to the read functions.
// I think the best thing to do would be to make it a generic param, then
// if users find it useful they can attach write number, or timestamp, etc.

/*//////////////////////////////////////////////////////////////
                               ERB
//////////////////////////////////////////////////////////////*/

/// @notice Low-level library for interacting with an expandable ring buffer.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibERB.sol)
library LibERB {
    struct ERBValue {
        uint224 value;
        uint32 writeNumber;
    }

    // Expected invariants:
    // - availableSlots >= 1
    // - totalWrites >= populatedSlots
    // - totalWrites < type(uint32).max
    // - availableSlots >= populatedSlots

    function grow(
        ERBValue[65535] storage self,
        uint16 growBy,
        uint16 availableSlots
    ) internal returns (uint16 newTotalAvailableSlots) {
        // This will overflow if we're trying to grow by too much.
        availableSlots = availableSlots + growBy;

        unchecked {
            for (uint256 i = availableSlots; i < newTotalAvailableSlots; i++)
                // We already implicitly assume we'll never
                // reach type(uint32).max many total writes.
                self[i].writeNumber = type(uint32).max;
        }
    }

    function write(
        ERBValue[65535] storage self,
        uint224 value,
        uint32 totalWrites,
        uint16 populatedSlots,
        uint16 availableSlots // Note: This MUST be at least 1.
    ) internal returns (uint32 newTotalWrites, uint16 newPopulatedSlots) {
        unchecked {
            newPopulatedSlots = populatedSlots == 0 || totalWrites % populatedSlots == (populatedSlots - 1)
                ? availableSlots
                : populatedSlots;

            newTotalWrites = totalWrites + 1; // This will overflow if we reach type(uint32).max writes.

            self[totalWrites % newPopulatedSlots] = ERBValue({writeNumber: newTotalWrites, value: value});
        }
    }

    function read(
        ERBValue[65535] storage self,
        uint32 totalWrites,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        // We use unsafeMod so that we use index 0 when populatedSlots is 0.
        return self[FixedPointMathLib.unsafeMod(totalWrites, populatedSlots)];
    }

    function readOffset(
        ERBValue[65535] storage self,
        uint32 offset,
        uint32 totalWrites,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        unchecked {
            // We can't read back further than our # of populated slots will allow.
            require(offset <= populatedSlots, "OUT_OF_BOUNDS");

            // We use unsafeMod so that we use index 0 when populatedSlots is 0.
            // We assume the invariant totalWrites >= populatedSlots is maintained.
            return self[FixedPointMathLib.unsafeMod(totalWrites - offset, populatedSlots)];
        }
    }

    function readWriteNumber(
        ERBValue[65535] storage self,
        uint32 writeNumber,
        uint32 totalWrites,
        uint16 populatedSlots
    ) internal view returns (ERBValue memory) {
        // We can't read back further than our # of populated slots will allow.
        // This will safely revert due to underflow if writeNumber > totalWrites.
        require(totalWrites - writeNumber <= populatedSlots, "OUT_OF_BOUNDS");

        // Return early if we just wan't the current value. We use
        // unsafeMod so that we use index 0 when populatedSlots is 0.
        return self[FixedPointMathLib.unsafeMod(writeNumber, populatedSlots)];
    }
}

/*//////////////////////////////////////////////////////////////
                            BOXED ERB
//////////////////////////////////////////////////////////////*/

/// @notice High-level library for interacting with a self-managing encapsulated ERB.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibERB.sol)
library LibBoxedERB {
    struct BoxedERB {
        uint32 totalWrites;
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
        // reach type(uint32).max many total writes.
        self.erb[0].writeNumber = type(uint32).max;
    }

    function grow(BoxedERB storage self, uint16 growBy) internal {
        self.availableSlots = self.erb.grow(growBy, self.availableSlots);
    }

    // This should only be called if init has been called before.
    function write(BoxedERB storage self, uint224 value) internal {
        (self.totalWrites, self.populatedSlots) = self.erb.write(
            value,
            self.totalWrites,
            self.populatedSlots,
            self.availableSlots
        );
    }

    function read(BoxedERB storage self) internal view returns (LibERB.ERBValue memory) {
        return self.erb.read(self.totalWrites, self.populatedSlots);
    }

    function readOffset(BoxedERB storage self, uint32 offset) internal view returns (LibERB.ERBValue memory) {
        return self.erb.readOffset(offset, self.totalWrites, self.populatedSlots);
    }

    function readWriteNumber(BoxedERB storage self, uint32 writeNumber) internal view returns (LibERB.ERBValue memory) {
        return self.erb.readWriteNumber(writeNumber, self.totalWrites, self.populatedSlots);
    }
}
