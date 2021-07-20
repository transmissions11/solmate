// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./MockERC20.sol";

contract ERC20User {
    MockERC20 token;

    constructor(MockERC20 _token) {
        token = _token;
    }

    function approve(address dst, uint256 amt) external {
        token.approve(dst, amt);
    }
}
