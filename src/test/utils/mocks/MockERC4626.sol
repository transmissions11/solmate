// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract MockERC4626 is ERC4626 {
    uint256 private _beforeWithdrawHookCalledAmount = 0;
    uint256 private _afterDepositHookCalledAmount = 0;

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC4626(_underlying, _name, _symbol) {}

    function beforeWithdraw(uint256) internal override {
        _beforeWithdrawHookCalledAmount++;
    }

    function afterDeposit(uint256) internal override {
        _afterDepositHookCalledAmount++;
    }

    function isBeforeWithdrawHookCalled() public view returns (uint256 times) {
        return _beforeWithdrawHookCalledAmount;
    }

    function isAfterDepositHookCalled() public view returns (uint256 times) {
        return _afterDepositHookCalledAmount;
    }
}
