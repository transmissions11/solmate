// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import {Auth} from "../../auth/Auth.sol";

contract RequiresAuth is Auth {
    bool public flag;

    function updateFlag() external requiresAuth {
        flag = true;
    }
}
