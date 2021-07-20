// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "../../tokens/Token.sol";

contract MockToken is Token {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) Token(_name, _symbol, _decimals) {}

    function mint(address to, uint256 value) external {
        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        _burn(from, value);
    }
}
