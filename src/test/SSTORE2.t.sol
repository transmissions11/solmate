// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/TestPlus.sol";
import {SSTORE2} from "../src/utils/SSTORE2.sol";

contract SSTORE2Test is TestPlus {
    function testWriteRead() public {
        bytes memory testBytes = abi.encode("this is a test");

        address pointer = SSTORE2.write(testBytes);

        assertEq(SSTORE2.read(pointer), testBytes);
    }

    function testWriteReadFullStartBound() public {
        assertEq(SSTORE2.read(SSTORE2.write(hex"11223344"), 0), hex"11223344");
    }

    function testWriteReadCustomStartBound() public {
        assertEq(SSTORE2.read(SSTORE2.write(hex"11223344"), 1), hex"223344");
    }

    function testWriteReadFullBoundedRead() public {
        bytes memory testBytes = abi.encode("this is a test");

        assertEq(SSTORE2.read(SSTORE2.write(testBytes), 0, testBytes.length), testBytes);
    }

    function testWriteReadCustomBounds() public {
        assertEq(SSTORE2.read(SSTORE2.write(hex"11223344"), 1, 3), hex"2233");
    }

    function testWriteReadEmptyBound() public {
        SSTORE2.read(SSTORE2.write(hex"11223344"), 3, 3);
    }

    function testReadInvalidPointerReverts() public {
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(address(1));
    }

    function testReadInvalidPointerCustomStartBoundReverts() public {
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(address(1), 1);
    }

    function testReadInvalidPointerCustomBoundsReverts() public {
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(address(1), 2, 4);
    }

    function testWriteReadOutOfStartBoundReverts() public {
        address pointer = SSTORE2.write(hex"11223344");
        vm.expectRevert(SSTORE2.ReadOutOfBounds.selector);
        SSTORE2.read(pointer, 41000);
    }

    function testWriteReadEmptyOutOfBoundsReverts() public {
        address pointer = SSTORE2.write(hex"11223344");
        vm.expectRevert(SSTORE2.ReadOutOfBounds.selector);
        SSTORE2.read(pointer, 42000, 42000);
    }

    function testWriteReadOutOfBoundsReverts() public {
        address pointer = SSTORE2.write(hex"11223344");
        vm.expectRevert(SSTORE2.ReadOutOfBounds.selector);
        SSTORE2.read(pointer, 41000, 42000);
    }

    function testFuzzWriteRead(bytes calldata testBytes, bytes calldata brutalizeWith)
        public
        brutalizeMemory(brutalizeWith)
    {
        assertEq(SSTORE2.read(SSTORE2.write(testBytes)), testBytes);
    }

    function testFuzzWriteReadCustomStartBound(
        bytes calldata testBytes,
        uint256 startIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (testBytes.length == 0) return;

        startIndex = bound(startIndex, 0, testBytes.length);

        assertEq(SSTORE2.read(SSTORE2.write(testBytes), startIndex), bytes(testBytes[startIndex:]));
    }

    function testFuzzWriteReadCustomBounds(
        bytes calldata testBytes,
        uint256 startIndex,
        uint256 endIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (testBytes.length == 0) return;

        endIndex = bound(endIndex, 0, testBytes.length);
        startIndex = bound(startIndex, 0, testBytes.length);

        if (startIndex > endIndex) return;

        assertEq(SSTORE2.read(SSTORE2.write(testBytes), startIndex, endIndex), bytes(testBytes[startIndex:endIndex]));
    }

    function testFuzzReadInvalidPointerRevert(address pointer, bytes calldata brutalizeWith)
        public
        brutalizeMemory(brutalizeWith)
    {
        if (pointer.code.length > 0) return;
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(pointer);
    }

    function testFuzzReadInvalidPointerCustomStartBoundReverts(
        address pointer,
        uint256 startIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (pointer.code.length > 0) return;
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(pointer, startIndex);
    }

    function testFuzzReadInvalidPointerCustomBoundsReverts(
        address pointer,
        uint256 startIndex,
        uint256 endIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (pointer.code.length > 0) return;
        vm.expectRevert(SSTORE2.InvalidPointer.selector);
        SSTORE2.read(pointer, startIndex, endIndex);
    }

    function testFuzzWriteReadCustomStartBoundOutOfRangeReverts(
        bytes calldata testBytes,
        uint256 startIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        startIndex = bound(startIndex, testBytes.length + 1, type(uint256).max);
        address pointer = SSTORE2.write(testBytes);
        vm.expectRevert(SSTORE2.ReadOutOfBounds.selector);
        SSTORE2.read(pointer, startIndex);
    }

    function testFuzzWriteReadCustomBoundsOutOfRangeReverts(
        bytes calldata testBytes,
        uint256 startIndex,
        uint256 endIndex,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        endIndex = bound(endIndex, testBytes.length + 1, type(uint256).max);
        address pointer = SSTORE2.write(testBytes);
        vm.expectRevert(SSTORE2.ReadOutOfBounds.selector);
        SSTORE2.read(pointer, startIndex, endIndex);
    }
}
