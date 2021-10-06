// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {Trust} from "../../auth/Trust.sol";

contract RequiresTrust is Trust(msg.sender) {
    bool public flag;

    function updateFlag() external requiresTrust {
        flag = true;
    }
}
