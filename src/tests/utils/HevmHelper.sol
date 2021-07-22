// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import {Hevm} from "./Hevm.sol";

abstract contract HevmUser {
    bytes20 internal constant CHEAT_CODE = bytes20(uint160(uint256(keccak256("hevm cheat code"))));

    Hevm internal constant hevm = Hevm(address(CHEAT_CODE));
}
