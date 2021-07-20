// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./MockToken.sol";

contract TokenUser {
    MockToken token;

    constructor(MockToken _token) {
        token = _token;
    }

    function approve(address dst, uint256 amt) external {
        token.approve(dst, amt);
    }
}
