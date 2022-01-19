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

    function deposit(address to, uint256 underlyingAmount) public virtual returns (uint256 shares) {
        return vault.deposit(to, underlyingAmount);
    }

    function mint(address to, uint256 shareAmount) public virtual returns (uint256 underlyingAmount) {
        return vault.mint(to, shareAmount);
    }

    function withdraw(
        address from,
        address to,
        uint256 underlyingAmount
    ) public virtual returns (uint256 shares) {
        return vault.withdraw(from, to, underlyingAmount);
    }

    function redeem(
        address from,
        address to,
        uint256 shareAmount
    ) public virtual returns (uint256 underlyingAmount) {
        return vault.redeem(from, to, shareAmount);
    }
}
