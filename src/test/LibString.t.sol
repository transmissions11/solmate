// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import {LibString} from "../src/utils/LibString.sol";

contract LibStringTest is Test {
    function testToStringZero() public {
        assertEq(keccak256(bytes(LibString.toString(0))), keccak256(bytes("0")));
    }

    function testToStringPositiveNumber() public {
        assertEq(keccak256(bytes(LibString.toString(4132))), keccak256(bytes("4132")));
    }

    function testToStringUint256Max() public {
        assertEq(
            keccak256(bytes(LibString.toString(type(uint256).max))),
            keccak256(bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935"))
        );
    }

    function testToStringZeroBrutalized() public {
        string memory s0 = LibString.toString(0);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        string memory s1 = LibString.toString(0);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        assertEq(keccak256(bytes(s0)), keccak256(bytes("0")));
        assertEq(keccak256(bytes(s1)), keccak256(bytes("0")));
    }

    function testToStringPositiveNumberBrutalized() public {
        string memory s0 = LibString.toString(4132);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        string memory s1 = LibString.toString(4132);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        assertEq(keccak256(bytes(s0)), keccak256(bytes("4132")));
        assertEq(keccak256(bytes(s1)), keccak256(bytes("4132")));
    }

    function testToStringUint256MaxBrutalized() public {
        string memory s0 = LibString.toString(type(uint256).max);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        string memory s1 = LibString.toString(type(uint256).max);
        assembly {
            mstore(mload(0x40), not(0))
            mstore(0x40, add(mload(0x40), 0x20))
        }
        assertEq(
            keccak256(bytes(s0)),
            keccak256(bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935"))
        );
        assertEq(
            keccak256(bytes(s1)),
            keccak256(bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935"))
        );
    }

    function testToHexStringZero() public {
        assertEq(keccak256(bytes(LibString.toHexString(0))), keccak256(bytes("0x00")));
    }

    function testToHexStringPositiveNumber() public {
        assertEq(keccak256(bytes(LibString.toHexString(0x4132))), keccak256(bytes("0x4132")));
    }

    function testToHexStringUint256Max() public {
        assertEq(
            keccak256(bytes(LibString.toHexString(type(uint256).max))),
            keccak256(bytes("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"))
        );
    }

    function testToHexStringFixedLengthPositiveNumberLong() public {
        assertEq(
            keccak256(bytes(LibString.toHexString(0x4132, 32))),
            keccak256(bytes("0x0000000000000000000000000000000000000000000000000000000000004132"))
        );
    }

    function testToHexStringFixedLengthPositiveNumberShort() public {
        assertEq(keccak256(bytes(LibString.toHexString(0x4132, 2))), keccak256(bytes("0x4132")));
    }

    function testToHexStringFixedLengthInsufficientLength() public {
        vm.expectRevert(LibString.HexLengthInsufficient.selector);
        LibString.toHexString(0x4132, 1);
    }

    function testToHexStringFixedLengthUint256Max() public {
        assertEq(
            keccak256(bytes(LibString.toHexString(type(uint256).max, 32))),
            keccak256(bytes("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"))
        );
    }

    function testFromAddressToHexString() public {
        assertEq(
            keccak256(bytes(LibString.toHexString(address(0xA9036907dCcae6a1E0033479B12E837e5cF5a02f)))),
            keccak256(bytes("0xa9036907dccae6a1e0033479b12e837e5cf5a02f"))
        );
    }

    function testFromAddressToHexStringWithLeadingZeros() public {
        assertEq(
            keccak256(bytes(LibString.toHexString(address(0x0000E0Ca771e21bD00057F54A68C30D400000000)))),
            keccak256(bytes("0x0000e0ca771e21bd00057f54a68c30d400000000"))
        );
    }

    function testStringReplaceShort() public {
        assertEq(LibString.replace("abc", "", "_@"), "_@a_@b_@c_@");
        assertEq(LibString.replace("abc", "a", "_"), "_bc");
        assertEq(LibString.replace("abc", "b", "_"), "a_c");
        assertEq(LibString.replace("abc", "c", "_"), "ab_");
        assertEq(LibString.replace("abc", "ab", "_"), "_c");
        assertEq(LibString.replace("abc", "bc", "_"), "a_");
        assertEq(LibString.replace("abc", "ac", "_"), "abc");
        assertEq(LibString.replace("abc", "a", ""), "bc");
        assertEq(LibString.replace("abc", "", ""), "abc");
        assertEq(LibString.replace("abc", "d", "x"), "abc");
    }

    function testStringReplaceMedium() public {
        // prettier-ignore
        string memory source = "70708741044725766535585242414884609539555049888764130733849700923779599488691391677696419266840";
        string memory search = "46095395550498887641307338497009";
        string memory replacement = "320807383223517906783031356692334377159141";
        // prettier-ignore
        string memory expectedResult = "707087410447257665355852424148832080738322351790678303135669233437715914123779599488691391677696419266840";
        assertEq(LibString.replace(source, search, replacement), expectedResult);
    }

    function testStringReplaceLong() public {
        // prettier-ignore
        string memory source = "01234567890123456789012345678901_search_search_search_search_search_search_23456789012345678901234567890123456789_search_search_search_search_search_search";
        string memory search = "search_search_search_search_search_search";
        string memory replacement = "REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT";
        // prettier-ignore
        string memory expectedResult = "01234567890123456789012345678901_REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT_23456789012345678901234567890123456789_REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT_REPLACEMENT";
        assertEq(LibString.replace(source, search, replacement), expectedResult);
    }
}
