// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract ERC4626User {
    ERC4626 token;
    ERC20 underlying;

    constructor(ERC4626 _token, ERC20 _underlying) {
        token = _token;
        underlying = _underlying;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        return token.approve(spender, amount);
    }

    function deposit(address to, uint256 underlyingAmount) public virtual returns (uint256 shares) {
        return token.deposit(to, underlyingAmount);
    }
}
