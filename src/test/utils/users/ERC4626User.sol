// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

import {ERC20User} from "./ERC20User.sol";

contract ERC4626User is ERC20User {
    ERC4626 vault;

    constructor(ERC4626 _vault, ERC20 _token) ERC20User(_token) {
        vault = _vault;
    }

    function deposit(uint256 amount, address to) public virtual returns (uint256 shares) {
        return vault.deposit(amount, to);
    }

    function mint(uint256 shares, address to) public virtual returns (uint256 underlyingAmount) {
        return vault.mint(shares, to);
    }

    function withdraw(
        uint256 amount,
        address to,
        address from
    ) public virtual returns (uint256 shares) {
        return vault.withdraw(amount, to, from);
    }

    function redeem(
        uint256 shares,
        address to,
        address from
    ) public virtual returns (uint256 underlyingAmount) {
        return vault.redeem(shares, to, from);
    }
}
