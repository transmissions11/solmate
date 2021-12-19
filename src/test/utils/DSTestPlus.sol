// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {DSTest} from "ds-test/test.sol";

import {Hevm} from "./Hevm.sol";

contract DSTestPlus is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    address internal constant DEAD_ADDRESS = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;

    string private checkpointLabel;
    uint256 private checkpointGasLeft;

    function startMeasuringGas(string memory label) internal virtual {
        checkpointLabel = label;
        checkpointGasLeft = gasleft();
    }

    function stopMeasuringGas() internal virtual {
        uint256 checkpointGasLeft2 = gasleft();

        string memory label = checkpointLabel;

        emit log_named_uint(string(abi.encodePacked(label, " Gas")), checkpointGasLeft - checkpointGasLeft2);
    }

    // Wrap x between the min and max (both inclusive), used for bounding the range of fuzzer inputs.
    // Source: https://stackoverflow.com/questions/14415753/wrap-value-into-range-min-max-without-division
    function wrap(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        // Add 1 to max to convert range from [min, max) to [min, max]
        // Note: We can only do this if the upper bound is not type(uint256).max, since otherwise
        // adding 1 will overflow. This means specifying a max value of type(uint256).max is the
        // only exclusive upper bound, as it results in an upper bound of type(uint256).max-1. As
        // a result, if you need a range of [n, type(uint256).max], you should call this method as
        // `x = wrap(x, n-1, type(uint256).max) + 1`
        max = max == type(uint256).max ? max : max + 1;
        return x < min ? max - (min - x) % (max - min) : min + (x - min) % (max - min);
    }

    function fail(string memory err) internal virtual {
        emit log_named_string("Error", err);
        fail();
    }

    function assertFalse(bool data) internal virtual {
        assertTrue(!data);
    }

    function assertUint128Eq(uint128 a, uint128 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint64Eq(uint64 a, uint64 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint96Eq(uint96 a, uint96 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertUint32Eq(uint32 a, uint32 b) internal virtual {
        assertEq(uint256(a), uint256(b));
    }

    function assertBytesEq(bytes memory a, bytes memory b) internal virtual {
        if (keccak256(a) != keccak256(b)) {
            emit log("Error: a == b not satisfied [bytes]");
            emit log_named_bytes("  Expected", b);
            emit log_named_bytes("    Actual", a);
            fail();
        }
    }
}
