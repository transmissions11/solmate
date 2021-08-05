// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

import {Auth} from "../../auth/Auth.sol";

contract RequiresAuth is Auth {
    bool public flag;

    function updateFlag() external requiresAuth {
        flag = true;
    }
}
