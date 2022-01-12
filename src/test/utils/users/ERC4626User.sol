// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract ERC4626User {
    ERC4626 vault;
    ERC20 underlying;

    constructor(ERC4626 _vault, ERC20 _underlying) {
        vault = _vault;
        underlying = _underlying;
    }
}
