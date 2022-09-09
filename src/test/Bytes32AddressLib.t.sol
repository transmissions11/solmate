// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Bytes32AddressLib} from "../utils/Bytes32AddressLib.sol";

contract Bytes32AddressLibTest is DSTestPlus {
    function testFillLast12Bytes() public {
        assertEq(
            Bytes32AddressLib.fillLast12Bytes(0xfEEDFaCEcaFeBEEFfEEDFACecaFEBeeFfeEdfAce),
            0xfeedfacecafebeeffeedfacecafebeeffeedface000000000000000000000000
        );
    }

    function testFromLast20Bytes() public {
        assertEq(
            Bytes32AddressLib.fromLast20Bytes(0xfeedfacecafebeeffeedfacecafebeeffeedfacecafebeeffeedfacecafebeef),
            0xCAfeBeefFeedfAceCAFeBEEffEEDfaCecafEBeeF
        );
    }
}
