// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {LibString} from "../utils/LibString.sol";

contract LibStringTest is DSTestPlus {
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
        hevm.expectRevert(LibString.HexLengthInsufficient.selector);
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

    function testFromAddressToHexStringChecksumed() public {
        // All caps.
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0x52908400098527886E0F7030069857D2E4169EE7)))),
            keccak256(bytes("0x52908400098527886E0F7030069857D2E4169EE7"))
        );
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0x8617E340B3D01FA5F11F306F4090FD50E238070D)))),
            keccak256(bytes("0x8617E340B3D01FA5F11F306F4090FD50E238070D"))
        );
        // All lower.
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0xde709f2102306220921060314715629080e2fb77)))),
            keccak256(bytes("0xde709f2102306220921060314715629080e2fb77"))
        );
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0x27b1fdb04752bbc536007a920d24acb045561c26)))),
            keccak256(bytes("0x27b1fdb04752bbc536007a920d24acb045561c26"))
        );
        // Normal.
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed)))),
            keccak256(bytes("0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"))
        );
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359)))),
            keccak256(bytes("0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"))
        );
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB)))),
            keccak256(bytes("0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB"))
        );
        assertEq(
            keccak256(bytes(LibString.toHexStringChecksumed(address(0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb)))),
            keccak256(bytes("0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb"))
        );
    }
}
