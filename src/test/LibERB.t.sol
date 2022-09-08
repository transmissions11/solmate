// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {LibERB, LibBoxedERB} from "../utils/LibERB.sol";

contract BoxedERBInvariants is DSTestPlus {
    using LibBoxedERB for LibBoxedERB.BoxedERB;

    BoxedERB boxedERB;

    function setUp() public {
        boxedERB = new BoxedERB();
    }

    function testReproduce() public {
        boxedERB.grow(10);

        emit log_uint(boxedERB.availableSlots());
        emit log_uint(boxedERB.populatedSlots());

        boxedERB.write(1);

        emit log_uint(boxedERB.availableSlots());
        emit log_uint(boxedERB.populatedSlots());

        require(boxedERB.read().updateNumber - 1 == boxedERB.readOffset(1).updateNumber);
    }

    function invariantMonotonicUpdateNumber() public {
        if (boxedERB.populatedSlots() < 2) return;

        emit log_uint(boxedERB.read().updateNumber - 1);
        emit log_uint(boxedERB.readOffset(1).updateNumber);

        require(boxedERB.read().updateNumber - 1 == boxedERB.readOffset(1).updateNumber);
    }

    function invariantPopulatedSlotsLeToAvailable() public {
        emit log_uint(boxedERB.populatedSlots());
        emit log_uint(boxedERB.availableSlots());
        require(boxedERB.populatedSlots() <= boxedERB.availableSlots());
        // assertLe(boxedERB.populatedSlots(), boxedERB.availableSlots());
    }
}

contract BoxedERB {
    using LibBoxedERB for LibBoxedERB.BoxedERB;

    LibBoxedERB.BoxedERB public boxedERB;

    constructor() {
        boxedERB.init();
    }

    function write(uint224 x) public {
        boxedERB.write(x);
    }

    function grow(uint16 growBy) public {
        boxedERB.grow(growBy);
    }

    function read() public view returns (LibERB.ERBValue memory) {
        return boxedERB.read();
    }

    function readOffset(uint32 offset) public view returns (LibERB.ERBValue memory) {
        return boxedERB.readOffset(offset);
    }

    function populatedSlots() public view returns (uint256) {
        return boxedERB.populatedSlots;
    }

    function availableSlots() public view returns (uint256) {
        return boxedERB.availableSlots;
    }
}
