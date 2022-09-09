// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {LibClone} from "../src/utils/LibClone.sol";
import {Clone} from "../src/utils/Clone.sol";

contract LibCloneTest is Test, Clone {
    error CustomError(uint256 currentValue);

    uint256 public value;

    mapping(bytes32 => bool) saltIsUsed;

    function setUp() public {
        value += 1;
    }

    function setValue(uint256 value_) public {
        value = value_;
    }

    function revertWithError() public view {
        revert CustomError(value);
    }

    function _shouldBehaveLikeClone(address clone, uint256 value_) internal {
        assertTrue(clone != address(0));

        uint256 thisValue = this.value();
        if (thisValue == value_) {
            value_ ^= 1;
        }
        LibCloneTest(clone).setValue(value_);
        assertEq(value_, LibCloneTest(clone).value());
        assertEq(thisValue, this.value());
        vm.expectRevert(abi.encodeWithSelector(CustomError.selector, value_));
        LibCloneTest(clone).revertWithError();
    }

    function testClone(uint256 value_) public {
        address clone = LibClone.clone(address(this));
        _shouldBehaveLikeClone(clone, value_);
    }

    function testClone() public {
        testClone(1);
    }

    function testCloneDeterministic(uint256 value_, bytes32 salt) public {
        if (saltIsUsed[salt]) {
            vm.expectRevert(LibClone.DeploymentFailed.selector);
            LibClone.cloneDeterministic(address(this), salt);
            return;
        }

        address clone = LibClone.cloneDeterministic(address(this), salt);
        saltIsUsed[salt] = true;

        _shouldBehaveLikeClone(clone, value_);

        address predicted = LibClone.predictDeterministicAddress(address(this), salt, address(this));
        assertEq(clone, predicted);
    }

    function testCloneDeterministicRevertsIfAddressAlreadyUsed() public {
        testCloneDeterministic(1, keccak256("a"));
        testCloneDeterministic(1, keccak256("a"));
    }

    function testCloneDeterministic() public {
        testCloneDeterministic(1, keccak256("b"));
    }

    function getArgAddress(uint256 argOffset) public pure returns (address) {
        return _getArgAddress(argOffset);
    }

    function getArgUint256(uint256 argOffset) public pure returns (uint256) {
        return _getArgUint256(argOffset);
    }

    function getArgUint256Array(uint256 argOffset, uint256 length) public pure returns (uint256[] memory) {
        return _getArgUint256Array(argOffset, length);
    }

    function getArgUint64(uint256 argOffset) public pure returns (uint64) {
        return _getArgUint64(argOffset);
    }

    function getArgUint8(uint256 argOffset) public pure returns (uint8) {
        return _getArgUint8(argOffset);
    }

    function testCloneWithImmutableArgs(
        uint256 value_,
        address argAddress,
        uint256 argUint256,
        uint256[] memory argUint256Array,
        uint64 argUint64,
        uint8 argUint8
    ) public {
        bytes memory data = abi.encodePacked(argAddress, argUint256, argUint256Array, argUint64, argUint8);
        LibCloneTest clone = LibCloneTest(LibClone.clone(address(this), data));
        _shouldBehaveLikeClone(address(clone), value_);
        uint256 argOffset;
        assertEq(clone.getArgAddress(argOffset), argAddress);
        argOffset += 20;
        assertEq(clone.getArgUint256(argOffset), argUint256);
        argOffset += 32;
        assertEq(clone.getArgUint256Array(argOffset, argUint256Array.length), argUint256Array);
        argOffset += 32 * argUint256Array.length;
        assertEq(clone.getArgUint64(argOffset), argUint64);
        argOffset += 8;
        assertEq(clone.getArgUint8(argOffset), argUint8);
    }

    function testCloneWithImmutableArgs() public {
        uint256[] memory argUint256Array = new uint256[](2);
        argUint256Array[0] = 111;
        argUint256Array[1] = 222;
        testCloneWithImmutableArgs(1, address(uint160(0xB00Ba5)), 8, argUint256Array, 7, 6);
    }

    function testCloneDeteministicWithImmutableArgs(
        uint256 value_,
        bytes32 salt,
        address argAddress,
        uint256 argUint256,
        uint256[] memory argUint256Array,
        uint64 argUint64,
        uint8 argUint8
    ) public {
        bytes memory data = abi.encodePacked(argAddress, argUint256, argUint256Array, argUint64, argUint8);
        bytes32 saltKey = keccak256(abi.encode(data, salt));

        if (saltIsUsed[saltKey]) {
            vm.expectRevert(LibClone.DeploymentFailed.selector);
            LibCloneTest(LibClone.cloneDeterministic(address(this), data, salt));
            return;
        }

        LibCloneTest clone = LibCloneTest(LibClone.cloneDeterministic(address(this), data, salt));

        saltIsUsed[saltKey] = true;

        _shouldBehaveLikeClone(address(clone), value_);

        uint256 argOffset;
        assertEq(clone.getArgAddress(argOffset), argAddress);
        argOffset += 20;
        assertEq(clone.getArgUint256(argOffset), argUint256);
        argOffset += 32;
        assertEq(clone.getArgUint256Array(argOffset, argUint256Array.length), argUint256Array);
        argOffset += 32 * argUint256Array.length;
        assertEq(clone.getArgUint64(argOffset), argUint64);
        argOffset += 8;
        assertEq(clone.getArgUint8(argOffset), argUint8);

        address predicted = LibClone.predictDeterministicAddress(address(this), data, salt, address(this));
        assertEq(address(clone), predicted);
    }
}
