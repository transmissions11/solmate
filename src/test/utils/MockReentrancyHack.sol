// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

contract MockReentrancyHack {
    IWETH weth;

    constructor(address _addr) {
        weth = IWETH(_addr);
    }

    function attack() external payable {
        require(address(this).balance == 1 ether);
        weth.deposit{value: 1 ether}();
        weth.withdraw(1 ether);
    }

    receive() external payable {
        if (address(weth).balance >= 1 ether) {
            weth.withdraw(1 ether);
        }
    }
}
