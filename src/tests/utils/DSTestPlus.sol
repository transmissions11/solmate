// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "ds-test/test.sol";

import {Hevm} from "./hevm.sol";
import {ERC20} from "../../erc20/ERC20.sol";

contract DSTestPlus is DSTest {
    Hevm constant hevm = Hevm(HEVM_ADDRESS);

    address immutable self = address(this);

    function fail(string memory err) internal {
        emit log_named_string("Error", err);
        fail();
    }

    function assertERC20Eq(ERC20 erc1, ERC20 erc2) internal {
        assertEq(address(erc1), address(erc2));
    }
}
