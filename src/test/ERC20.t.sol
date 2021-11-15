// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {ERC20User} from "./utils/users/ERC20User.sol";

contract ERC20Test is DSTestPlus {
    MockERC20 token;

    function setUp() public {
        token = new MockERC20("Token", "TKN", 18);
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.decimals(), 18);
    }

    function testMetaData(
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) public {
        MockERC20 tkn = new MockERC20(name, symbol, decimals);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
        assertEq(tkn.decimals(), decimals);
    }

    function testMint(address from, uint256 amount) public {
        token.mint(from, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(from), amount);
    }

    function testBurn(
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        if (burnAmount > mintAmount) return;

        token.mint(from, mintAmount);
        token.burn(from, burnAmount);

        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(from), mintAmount - burnAmount);
    }

    function testApprove(address from, uint256 amount) public {
        assertTrue(token.approve(from, amount));

        assertEq(token.allowance(address(this), from), amount);
    }

    function testTransfer(address from, uint256 amount) public {
        token.mint(address(this), amount);

        assertTrue(token.transfer(from, amount));
        assertEq(token.totalSupply(), amount);

        if (address(this) == from) {
            assertEq(token.balanceOf(address(this)), amount);
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(from), amount);
        }
    }

    function testTransferFrom(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        if (amount > approval) return;

        ERC20User from = new ERC20User(token);

        token.mint(address(from), amount);

        from.approve(address(this), approval);

        assertTrue(token.transferFrom(address(from), to, amount));
        assertEq(token.totalSupply(), amount);

        uint256 app = address(from) == address(this) || approval == type(uint256).max ? approval : approval - amount;
        assertEq(token.allowance(address(from), address(this)), app);

        if (address(from) == to) {
            assertEq(token.balanceOf(address(from)), amount);
        } else {
            assertEq(token.balanceOf(address(from)), 0);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testFailTransferFromInsufficientAllowance(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        require(approval < amount);

        ERC20User from = new ERC20User(token);

        token.mint(address(from), amount);
        from.approve(address(this), approval);
        token.transferFrom(address(from), to, amount);
    }

    function testFailTransferFromInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        require(mintAmount < sendAmount);

        ERC20User from = new ERC20User(token);

        token.mint(address(from), mintAmount);
        from.approve(address(this), sendAmount);
        token.transferFrom(address(from), to, sendAmount);
    }
}

contract ERC20Invariants is DSTestPlus, DSInvariantTest {
    BalanceSum balanceSum;
    MockERC20 token;

    function setUp() public {
        token = new MockERC20("Token", "TKN", 18);
        balanceSum = new BalanceSum(token);

        addTargetContract(address(balanceSum));
    }

    function invariantBalanceSum() public {
        assertEq(token.totalSupply(), balanceSum.sum());
    }
}

contract BalanceSum {
    MockERC20 token;
    uint256 public sum;

    constructor(MockERC20 _token) {
        token = _token;
    }

    function mint(address from, uint256 amount) public {
        token.mint(from, amount);
        sum += amount;
    }

    function burn(address from, uint256 amount) public {
        token.burn(from, amount);
        sum -= amount;
    }

    function approve(address to, uint256 amount) public {
        token.approve(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public {
        token.transferFrom(from, to, amount);
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }
}
