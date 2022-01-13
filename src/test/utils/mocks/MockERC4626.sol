// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../../../tokens/ERC20.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract MockERC4626 is ERC4626 {
    bool public isBeforeWithdrawHookCalled = false;
    bool public isAfterDepositHookCalled = false;

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC4626(_underlying, _name, _symbol) {}

    function totalHoldings() public view override returns (uint256) {
        return underlying.balanceOf(address(this));
    }

    function beforeWithdraw(uint256) internal override {
        isBeforeWithdrawHookCalled = true;
    }

    function afterDeposit(uint256) internal override {
        isAfterDepositHookCalled = true;
    }
}
