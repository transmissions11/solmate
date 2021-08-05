// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "ds-test/test.sol";

import {Hevm} from "./Hevm.sol";
import {ERC20} from "../../erc20/ERC20.sol";

contract DSTestPlus is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    address internal immutable self = address(this);

    uint256 checkpointGasLeft;
    string checkpointLabel;

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

    function assertERC20Eq(ERC20 erc1, ERC20 erc2) internal {
        assertEq(address(erc1), address(erc2));
    }

    function assertEq(uint128 num1, uint128 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }

    function assertEq(uint64 num1, uint64 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }

    function assertEq(uint32 num1, uint32 num2) internal {
        assertEq(uint256(num1), uint256(num2));
    }
}
