// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "weird-erc20/ERC20.sol";
import {ReturnsFalseToken} from "weird-erc20/ReturnsFalse.sol";
import {MissingReturnToken} from "weird-erc20/MissingReturns.sol";
import {TransferFromSelfToken} from "weird-erc20/TransferFromSelf.sol";
import {PausableToken} from "weird-erc20/Pausable.sol";

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {SafeTransferLib, ERC20 as SolmateERC20} from "../utils/SafeTransferLib.sol";

contract SafeTransferLibTest is DSTestPlus {
    ReturnsFalseToken returnsFalse;
    MissingReturnToken missingReturn;
    TransferFromSelfToken transferFromSelf;
    PausableToken pausable;

    ERC20 erc20;

    function setUp() public {
        returnsFalse = new ReturnsFalseToken(type(uint256).max);
        missingReturn = new MissingReturnToken(type(uint256).max);
        transferFromSelf = new TransferFromSelfToken(type(uint256).max);

        pausable = new PausableToken(type(uint256).max);
        pausable.stop();

        erc20 = new ERC20(type(uint256).max);
    }

    function testTransferWithMissingReturn() public {
        verifySafeTransfer(address(missingReturn), address(0xBEEF), 1e18);
    }

    function testTransferWithTransferFromSelf() public {
        verifySafeTransfer(address(transferFromSelf), address(0xBEEF), 1e18);
    }

    function testTransferWithStandardERC20() public {
        verifySafeTransfer(address(erc20), address(0xBEEF), 1e18);
    }

    function testTransferWithNonContract() public {
        SafeTransferLib.safeTransfer(SolmateERC20(address(0xBADBEEF)), address(0xBEEF), 1e18);
    }

    function testTransferFromWithMissingReturn() public {
        verifySafeTransferFrom(address(missingReturn), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testTransferFromWithTransferFromSelf() public {
        verifySafeTransferFrom(address(transferFromSelf), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testTransferFromWithStandardERC20() public {
        verifySafeTransferFrom(address(erc20), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testTransferFromWithNonContract() public {
        SafeTransferLib.safeTransferFrom(SolmateERC20(address(0xBADBEEF)), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testApproveWithMissingReturn() public {
        verifySafeApprove(address(missingReturn), address(0xBEEF), 1e18);
    }

    function testApproveWithTransferFromSelf() public {
        verifySafeApprove(address(transferFromSelf), address(0xBEEF), 1e18);
    }

    function testApproveWithStandardERC20() public {
        verifySafeApprove(address(transferFromSelf), address(0xBEEF), 1e18);
    }

    function testApproveWithNonContract() public {
        SafeTransferLib.safeApprove(SolmateERC20(address(0xBADBEEF)), address(0xBEEF), 1e18);
    }

    function testTransferETH() public {
        SafeTransferLib.safeTransferETH(address(0xBEEF), 1e18);
    }

    function testFailTransferWithReturnsFalse() public {
        verifySafeTransfer(address(returnsFalse), address(0xBEEF), 1e18);
    }

    function testFailTransferWithPausable() public {
        verifySafeTransfer(address(pausable), address(0xBEEF), 1e18);
    }

    function testFailTransferFromWithReturnsFalse() public {
        verifySafeTransferFrom(address(returnsFalse), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testFailTransferFromWithPausable() public {
        verifySafeTransferFrom(address(pausable), address(0xFEED), address(0xBEEF), 1e18);
    }

    function testFailApproveWithReturnsFalse() public {
        verifySafeApprove(address(returnsFalse), address(0xBEEF), 1e18);
    }

    function testFailApproveWithPausable() public {
        verifySafeApprove(address(pausable), address(0xBEEF), 1e18);
    }

    function testTransferWithMissingReturn(address to, uint256 amount) public {
        verifySafeTransfer(address(missingReturn), to, amount);
    }

    function testTransferWithTransferFromSelf(address to, uint256 amount) public {
        verifySafeTransfer(address(transferFromSelf), to, amount);
    }

    function testTransferWithStandardERC20(address to, uint256 amount) public {
        verifySafeTransfer(address(erc20), to, amount);
    }

    function testFailTransferETHToContractWithoutFallback() public {
        SafeTransferLib.safeTransferETH(address(this), 1e18);
    }

    function testTransferWithNonContract(
        address nonContract,
        address to,
        uint256 amount
    ) public {
        if (nonContract.code.length > 0) return;

        if (uint256(uint160(nonContract)) <= 18) return; // Some precompiles cause reverts.

        SafeTransferLib.safeTransfer(SolmateERC20(nonContract), to, amount);
    }

    function testTransferFromWithMissingReturn(
        address from,
        address to,
        uint256 amount
    ) public {
        verifySafeTransferFrom(address(missingReturn), from, to, amount);
    }

    function testTransferFromWithTransferFromSelf(
        address from,
        address to,
        uint256 amount
    ) public {
        verifySafeTransferFrom(address(transferFromSelf), from, to, amount);
    }

    function testTransferFromWithStandardERC20(
        address from,
        address to,
        uint256 amount
    ) public {
        verifySafeTransferFrom(address(erc20), from, to, amount);
    }

    function testTransferFromWithNonContract(
        address nonContract,
        address from,
        address to,
        uint256 amount
    ) public {
        if (nonContract.code.length > 0) return;

        if (uint256(uint160(nonContract)) <= 18) return; // Some precompiles cause reverts.

        SafeTransferLib.safeTransferFrom(SolmateERC20(nonContract), from, to, amount);
    }

    function testApproveWithMissingReturn(address to, uint256 amount) public {
        verifySafeApprove(address(missingReturn), to, amount);
    }

    function testApproveWithTransferFromSelf(address to, uint256 amount) public {
        verifySafeApprove(address(transferFromSelf), to, amount);
    }

    function testApproveWithStandardERC20(address to, uint256 amount) public {
        verifySafeApprove(address(transferFromSelf), to, amount);
    }

    function testApproveWithNonContract(
        address nonContract,
        address to,
        uint256 amount
    ) public {
        if (nonContract.code.length > 0) return;

        if (uint256(uint160(nonContract)) <= 18) return; // Some precompiles cause reverts.

        SafeTransferLib.safeApprove(SolmateERC20(nonContract), to, amount);
    }

    function testTransferETH(address recipient, uint256 amount) public {
        if (uint256(uint160(recipient)) <= 18) return; // Some precompiles cause reverts.

        amount %= address(this).balance;

        SafeTransferLib.safeTransferETH(recipient, amount);
    }

    function testFailTransferWithReturnsFalse(address to, uint256 amount) public {
        verifySafeTransfer(address(returnsFalse), to, amount);
    }

    function testFailTransferWithPausable(address to, uint256 amount) public {
        verifySafeTransfer(address(pausable), to, amount);
    }

    function testFailTransferFromWithReturnsFalse(
        address from,
        address to,
        uint256 amount
    ) public {
        verifySafeTransferFrom(address(returnsFalse), from, to, amount);
    }

    function testFailTransferFromWithPausable(
        address from,
        address to,
        uint256 amount
    ) public {
        verifySafeTransferFrom(address(pausable), from, to, amount);
    }

    function testFailApproveWithReturnsFalse(address to, uint256 amount) public {
        verifySafeApprove(address(returnsFalse), to, amount);
    }

    function testFailApproveWithPausable(address to, uint256 amount) public {
        verifySafeApprove(address(pausable), to, amount);
    }

    function testFailTransferETHToContractWithoutFallback(uint256 amount) public {
        SafeTransferLib.safeTransferETH(address(this), amount);
    }

    function verifySafeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 preBal = ERC20(token).balanceOf(to);
        SafeTransferLib.safeTransfer(SolmateERC20(address(token)), to, amount);
        uint256 postBal = ERC20(token).balanceOf(to);

        if (to == address(this)) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amount);
        }
    }

    function verifySafeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        forceApprove(token, from, address(this), amount);
        SafeTransferLib.safeTransfer(SolmateERC20(token), from, amount);

        uint256 preBal = ERC20(token).balanceOf(to);
        SafeTransferLib.safeTransferFrom(SolmateERC20(token), from, to, amount);
        uint256 postBal = ERC20(token).balanceOf(to);

        if (from == to) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amount);
        }
    }

    function verifySafeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        SafeTransferLib.safeApprove(SolmateERC20(address(token)), to, amount);

        assertEq(ERC20(token).allowance(address(this), to), amount);
    }

    function forceApprove(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 slot = token == address(erc20) || token == address(pausable) ? 3 : 2;

        hevm.store(
            token,
            keccak256(abi.encode(to, keccak256(abi.encode(from, uint256(slot))))),
            bytes32(uint256(amount))
        );

        assertEq(ERC20(token).allowance(from, to), amount, "wrong allowance");
    }
}
