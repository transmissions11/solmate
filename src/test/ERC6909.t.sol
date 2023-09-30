// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC6909} from "./utils/mocks/MockERC6909.sol";

contract ERC6909Test is DSTestPlus {
    MockERC6909 token;

    mapping(address => mapping(uint256 => uint256)) public userMintAmounts;
    mapping(address => mapping(uint256 => uint256)) public userTransferOrBurnAmounts;

    function setUp() public {
        token = new MockERC6909();
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1337, 100);

        assertEq(token.balanceOf(address(0xBEEF), 1337), 100);
        assertEq(token.totalSupply(1337), 100);
    }

    function testBurn() public {
        token.mint(address(0xBEEF), 1337, 100);
        token.burn(address(0xBEEF), 1337, 70);

        assertEq(token.balanceOf(address(0xBEEF), 1337), 30);
        assertEq(token.totalSupply(1337), 30);
    }

    function testSetOperator() public {
        token.setOperator(address(0xBEEF), true);

        assertTrue(token.isOperator(address(this), address(0xBEEF)));
    }

    function testApprove() public {
        token.approve(address(0xBEEF), 1337, 100);

        assertEq(token.allowance(address(this), address(0xBEEF), 1337), 100);
    }

    function testTransfer() public {
        address sender = address(0xABCD);

        token.mint(sender, 1337, 100);

        hevm.prank(sender);
        token.transfer(address(0xBEEF), 1337, 70);

        assertEq(token.balanceOf(sender, 1337), 30);
        assertEq(token.balanceOf(address(0xBEEF), 1337), 70);
    }

    function testTransferFromWithApproval() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        token.mint(sender, 1337, 100);

        hevm.prank(sender);
        token.approve(address(this), 1337, 100);

        token.transferFrom(sender, receiver, 1337, 70);

        assertEq(token.allowance(sender, address(this), 1337), 30);
        assertEq(token.balanceOf(sender, 1337), 30);
        assertEq(token.balanceOf(receiver, 1337), 70);
    }

    function testTransferFromWithInfiniteApproval() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        token.mint(sender, 1337, 100);

        hevm.prank(sender);
        token.approve(address(this), 1337, type(uint256).max);

        token.transferFrom(sender, receiver, 1337, 70);

        assertEq(token.allowance(sender, address(this), 1337), type(uint256).max);
        assertEq(token.balanceOf(sender, 1337), 30);
        assertEq(token.balanceOf(receiver, 1337), 70);
    }

    function testTransferFromAsOperator() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        token.mint(sender, 1337, 100);

        hevm.prank(sender);
        token.setOperator(address(this), true);

        token.transferFrom(sender, receiver, 1337, 70);

        assertEq(token.balanceOf(sender, 1337), 30);
        assertEq(token.balanceOf(receiver, 1337), 70);
    }

    function testFailMint() public {
        token.mint(address(0xDEAD), 1337, type(uint256).max);
        token.mint(address(0xBEEF), 1337, 1);
    }

    function testFailTransfer() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        hevm.prank(sender);
        token.transferFrom(sender, receiver, 1337, 1);
    }

    function testFailTransferFrom() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        hevm.prank(sender);
        token.transferFrom(sender, receiver, 1337, 1);
    }

    function testFailTransferFromNotAuthorized() public {
        address sender = address(0xABCD);
        address receiver = address(0xBEEF);

        token.mint(sender, 1337, 100);

        token.transferFrom(sender, receiver, 1337, 100);
    }

    function testMint(
        address receiver,
        uint256 id,
        uint256 amount
    ) public {
        token.mint(receiver, id, amount);

        assertEq(token.balanceOf(receiver, id), amount);
        assertEq(token.totalSupply(id), amount);
    }

    function testBurn(
        address sender,
        uint256 id,
        uint256 amount
    ) public {
        token.mint(sender, id, amount);
        token.burn(sender, id, amount);

        assertEq(token.balanceOf(sender, id), 0);
        assertEq(token.totalSupply(id), 0);
    }

    function testSetOperator(address operator, bool approved) public {
        token.setOperator(operator, approved);

        assertBoolEq(token.isOperator(address(this), operator), approved);
    }

    function testApprove(
        address spender,
        uint256 id,
        uint256 amount
    ) public {
        token.approve(spender, id, amount);

        assertEq(token.allowance(address(this), spender, id), amount);
    }

    function testTransfer(
        address sender,
        address receiver,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(sender, id, mintAmount);

        hevm.prank(sender);
        token.transfer(receiver, id, transferAmount);

        if (sender == receiver) {
            assertEq(token.balanceOf(sender, id), mintAmount);
        } else {
            assertEq(token.balanceOf(sender, id), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver, id), transferAmount);
        }
    }

    function testTransferFromWithApproval(
        address sender,
        address receiver,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(sender, id, mintAmount);

        hevm.prank(sender);
        token.approve(address(this), id, mintAmount);

        token.transferFrom(sender, receiver, id, transferAmount);

        if (mintAmount == type(uint256).max) {
            assertEq(token.allowance(sender, address(this), id), type(uint256).max);
        } else {
            assertEq(token.allowance(sender, address(this), id), mintAmount - transferAmount);
        }

        if (sender == receiver) {
            assertEq(token.balanceOf(sender, id), mintAmount);
        } else {
            assertEq(token.balanceOf(sender, id), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver, id), transferAmount);
        }
    }

    function testTransferFromWithInfiniteApproval(
        address sender,
        address receiver,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(sender, id, mintAmount);

        hevm.prank(sender);
        token.approve(address(this), id, type(uint256).max);

        token.transferFrom(sender, receiver, id, transferAmount);

        assertEq(token.allowance(sender, address(this), id), type(uint256).max);

        if (sender == receiver) {
            assertEq(token.balanceOf(sender, id), mintAmount);
        } else {
            assertEq(token.balanceOf(sender, id), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver, id), transferAmount);
        }
    }

    function testTransferFromAsOperator(
        address sender,
        address receiver,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(sender, id, mintAmount);

        hevm.prank(sender);
        token.setOperator(address(this), true);

        token.transferFrom(sender, receiver, id, transferAmount);

        if (sender == receiver) {
            assertEq(token.balanceOf(sender, id), mintAmount);
        } else {
            assertEq(token.balanceOf(sender, id), mintAmount - transferAmount);
            assertEq(token.balanceOf(receiver, id), transferAmount);
        }
    }

    function testFailTransfer(
        address sender,
        address receiver,
        uint256 id,
        uint256 amount
    ) public {
        amount = bound(amount, 1, type(uint256).max);

        hevm.prank(sender);
        token.transfer(receiver, id, amount);
    }

    function testFailTransferFrom(
        address sender,
        address receiver,
        uint256 id,
        uint256 amount
    ) public {
        amount = bound(amount, 1, type(uint256).max);

        hevm.prank(sender);
        token.transferFrom(sender, receiver, id, amount);
    }

    function testFailTransferFromNotAuthorized(
        address sender,
        address receiver,
        uint256 id,
        uint256 amount
    ) public {
        amount = bound(amount, 1, type(uint256).max);

        token.mint(sender, id, amount);

        token.transferFrom(sender, receiver, id, amount);
    }
}
