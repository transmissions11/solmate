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

    function assertERC20Eq(ERC20 erc1, ERC20 erc2) internal {
        assertEq(address(erc1), address(erc2));
    }

    function assertFalse(bool data) internal {
        assertTrue(!data);
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
}
