// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import "ds-test/test.sol";

import {Hevm} from "./Hevm.sol";

contract DSTestPlus is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    address internal immutable self = address(this);

    address internal constant DEAD_ADDRESS = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;

    uint256 private checkpointGasLeft;
    string private checkpointLabel;

    function fail(string memory err) internal {
        emit log_named_string("Error", err);
        fail();
    }

    function startMeasuringGas(string memory label) internal {
        checkpointLabel = label;
        checkpointGasLeft = gasleft();
    }

    function stopMeasuringGas() internal {
        uint256 checkpointGasLeft2 = gasleft();

        string memory label = checkpointLabel;

        emit log_named_uint(string(abi.encodePacked(label, " Gas")), checkpointGasLeft - checkpointGasLeft2);
    }

    function assertFalse(bool data) internal {
        assertTrue(!data);
    }

    function assertUint128Eq(uint128 num1, uint128 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }

    function assertUint64Eq(uint64 num1, uint64 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }

    function assertUint32Eq(uint32 num1, uint32 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }
}
