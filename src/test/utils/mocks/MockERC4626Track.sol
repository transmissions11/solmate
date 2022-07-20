// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract MockERC4626Track is ERC4626 {
    uint256 private balance;

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC4626(_underlying, _name, _symbol) {}

    function totalAssets() public view override returns (uint256) {
        return balance;
    }

    function beforeWithdraw(uint256 assets, uint256) internal override {
        balance -= assets;
    }

    function afterDeposit(uint256 assets, uint256) internal override {
        balance += assets;
    }
}
