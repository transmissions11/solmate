// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {ECDSA} from "src/utils/ECDSA.sol";
import {DSTest} from "ds-test/test.sol";

interface Vm {
    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
    function addr(uint256 privateKey) external returns (address);
}

contract ECDSATest is DSTest {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function testRecoverValidSignature() public {
        bytes32 message = keccak256("hello solmate");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message);
        address expected = vm.addr(1);

        bytes memory sig = abi.encodePacked(r, s, v);
        address recovered = ECDSA.recover(message, sig);

        assertEq(recovered, expected);
    }

    function testInvalidSigLength() public {
        address recovered = ECDSA.recover(keccak256("msg"), hex"1234");
        assertEq(recovered, address(0));
    }

    function testWrongSignatureReturnsZero() public {
    address recovered = ECDSA.recover(
        keccak256("hello"),
        hex"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabb"
    );

    emit log_address(recovered); // <-- This will print the address
    assertEq(recovered, address(0));
}
    function testMalleableSignature() public {
        bytes32 message = keccak256("test");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, message);

        // Modify the signature to make it malleable
        bytes memory sig = abi.encodePacked(r, s, v + 1); // Invalid v value

        address recovered = ECDSA.recover(message, sig);
        assertEq(recovered, address(0)); // Should return zero for malleable signature
    }
}
