// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC4626} from "../../../mixins/ERC4626.sol";

contract ERC4626User {
    ERC4626 token;

    constructor(ERC4626 _token) {
        token = _token;
    }
}
