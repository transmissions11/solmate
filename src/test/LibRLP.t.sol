// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {LibRLP} from "../src/utils/LibRLP.sol";

contract LibRLPTest is Test {
    function testComputeAddressDifferential(address deployer, uint256 nonce) public {
        assertEq(LibRLP.computeAddress(deployer, nonce), computeAddressOriginal(deployer, nonce));
    }

    function testComputeAddressForSmallNonces() public {
        address deployer = address(1);
        assertTrue(LibRLP.computeAddress(deployer, 1) != address(0));
        assertTrue(LibRLP.computeAddress(deployer, 0x7f) != address(0));
        assertTrue(LibRLP.computeAddress(deployer, 0xff) != address(0));
    }

    function testComputeAddressOriginalForSmallNonces() public {
        address deployer = address(1);
        assertTrue(computeAddressOriginal(deployer, 1) != address(0));
        assertTrue(computeAddressOriginal(deployer, 0x7f) != address(0));
        assertTrue(computeAddressOriginal(deployer, 0xff) != address(0));
    }

    function testComputeAddressForLargeNonces() public {
        address deployer = address(1);
        assertTrue(LibRLP.computeAddress(deployer, 0xffffffff) != address(0));
        assertTrue(LibRLP.computeAddress(deployer, 0xffffffffffffff) != address(0));
        assertTrue(LibRLP.computeAddress(deployer, 0xffffffffffffffff) != address(0));
    }

    function testComputeAddressOriginalForLargeNonces() public {
        address deployer = address(1);
        assertTrue(computeAddressOriginal(deployer, 0xffffffff) != address(0));
        assertTrue(computeAddressOriginal(deployer, 0xffffffffffffff) != address(0));
        assertTrue(computeAddressOriginal(deployer, 0xffffffffffffffff) != address(0));
    }

    function computeAddressOriginal(address deployer, uint256 nonce) internal pure returns (address) {
        // Although the theoretical allowed limit, based on EIP-2681,
        // for an account nonce is 2**64-2: https://eips.ethereum.org/EIPS/eip-2681,
        // we just test all the way to 2**256-1 to ensure that the computeAddress function does not revert
        // for whatever nonce we provide.
        // prettier-ignore
        if (nonce == 0x00) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x80))))));
        // prettier-ignore
        if (nonce <= 0x7f) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, uint8(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint8).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployer, bytes1(0x81), uint8(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint16).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployer, bytes1(0x82), uint16(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint24).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployer, bytes1(0x83), uint24(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint32).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xda), bytes1(0x94), deployer, bytes1(0x84), uint32(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint40).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xdb), bytes1(0x94), deployer, bytes1(0x85), uint40(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint48).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xdc), bytes1(0x94), deployer, bytes1(0x86), uint48(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint56).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xdd), bytes1(0x94), deployer, bytes1(0x87), uint56(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint64).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xde), bytes1(0x94), deployer, bytes1(0x88), uint64(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint72).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xdf), bytes1(0x94), deployer, bytes1(0x89), uint72(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint80).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe0), bytes1(0x94), deployer, bytes1(0x8a), uint80(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint88).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe1), bytes1(0x94), deployer, bytes1(0x8b), uint88(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint96).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe2), bytes1(0x94), deployer, bytes1(0x8c), uint96(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint104).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe3), bytes1(0x94), deployer, bytes1(0x8d), uint104(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint112).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe4), bytes1(0x94), deployer, bytes1(0x8e), uint112(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint120).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe5), bytes1(0x94), deployer, bytes1(0x8f), uint120(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint128).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe6), bytes1(0x94), deployer, bytes1(0x90), uint128(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint136).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe7), bytes1(0x94), deployer, bytes1(0x91), uint136(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint144).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe8), bytes1(0x94), deployer, bytes1(0x92), uint144(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint152).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xe9), bytes1(0x94), deployer, bytes1(0x93), uint152(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint160).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xea), bytes1(0x94), deployer, bytes1(0x94), uint160(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint168).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xeb), bytes1(0x94), deployer, bytes1(0x95), uint168(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint176).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xec), bytes1(0x94), deployer, bytes1(0x96), uint176(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint184).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xed), bytes1(0x94), deployer, bytes1(0x97), uint184(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint192).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xee), bytes1(0x94), deployer, bytes1(0x98), uint192(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint200).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xef), bytes1(0x94), deployer, bytes1(0x99), uint200(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint208).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf0), bytes1(0x94), deployer, bytes1(0x9a), uint208(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint216).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf1), bytes1(0x94), deployer, bytes1(0x9b), uint216(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint224).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf2), bytes1(0x94), deployer, bytes1(0x9c), uint224(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint232).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf3), bytes1(0x94), deployer, bytes1(0x9d), uint232(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint240).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf4), bytes1(0x94), deployer, bytes1(0x9e), uint240(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint248).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf5), bytes1(0x94), deployer, bytes1(0x9f), uint248(nonce))))));
        // prettier-ignore
        if (nonce <= type(uint256).max) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xf6), bytes1(0x94), deployer, bytes1(0xa0), uint256(nonce))))));
        revert();
    }
}
