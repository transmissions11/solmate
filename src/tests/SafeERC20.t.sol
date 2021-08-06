// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {SafeERC20, ERC20 as SolmateERC20} from "../erc20/SafeERC20.sol";

// TODO: Upgrade weird-erc20 once they upgrade ds-test.
import {ERC20} from "weird-erc20/ERC20.sol";
import {ReturnsFalseToken} from "weird-erc20/ReturnsFalse.sol";
import {MissingReturnToken} from "weird-erc20/MissingReturns.sol";
import {TransferFromSelfToken} from "weird-erc20/TransferFromSelf.sol";

contract SafeERC20Test is DSTestPlus {
    ReturnsFalseToken returnsFalse;
    MissingReturnToken missingReturn;
    TransferFromSelfToken transferFromSelf;

    ERC20 erc20;

    function setUp() public {
        returnsFalse = new ReturnsFalseToken(type(uint256).max);
        missingReturn = new MissingReturnToken(type(uint256).max);
        transferFromSelf = new TransferFromSelfToken(type(uint256).max);

        erc20 = new ERC20(type(uint256).max);
    }

    function proveWithMissingReturn(address dst, uint256 amt) public {
        verifySafeTransfer(address(missingReturn), dst, amt);
    }

    function proveWithMissingReturn(
        address src,
        address dst,
        uint256 amt
    ) public {
        verifySafeTransferFrom(address(missingReturn), src, dst, amt);
    }

    function proveWithTransferFromSelf(address dst, uint256 amt) public {
        verifySafeTransfer(address(transferFromSelf), dst, amt);
    }

    function proveWithTransferFromSelf(
        address src,
        address dst,
        uint256 amt
    ) public {
        verifySafeTransferFrom(address(transferFromSelf), src, dst, amt);
    }

    function proveWithStandardERC20(address dst, uint256 amt) public {
        verifySafeTransfer(address(erc20), dst, amt);
    }

    function proveWithStandardERC20(
        address src,
        address dst,
        uint256 amt
    ) public {
        verifySafeTransferFrom(address(erc20), src, dst, amt);
    }

    function proveFailWithReturnsFalse(address dst, uint256 amt) public {
        verifySafeTransfer(address(returnsFalse), dst, amt);
    }

    function proveFailWithReturnsFalse(
        address src,
        address dst,
        uint256 amt
    ) public {
        verifySafeTransferFrom(address(returnsFalse), src, dst, amt);
    }

    function verifySafeTransfer(
        address token,
        address dst,
        uint256 amt
    ) internal {
        uint256 preBal = ERC20(token).balanceOf(dst);
        SafeERC20.safeTransfer(SolmateERC20(address(token)), dst, amt);
        uint256 postBal = ERC20(token).balanceOf(dst);

        if (dst == address(this)) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amt);
        }
    }

    function verifySafeTransferFrom(
        address token,
        address src,
        address dst,
        uint256 amt
    ) internal {
        forceApprove(token, src, address(this), amt);
        SafeERC20.safeTransfer(SolmateERC20(token), src, amt);

        uint256 preBal = ERC20(token).balanceOf(dst);
        SafeERC20.safeTransferFrom(SolmateERC20(token), src, dst, amt);
        uint256 postBal = ERC20(token).balanceOf(dst);

        if (src == dst) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amt);
        }
    }

    function forceApprove(
        address token,
        address src,
        address dst,
        uint256 amt
    ) internal {
        uint256 slot = token == address(erc20) ? 3 : 2;
        hevm.store(token, keccak256(abi.encode(dst, keccak256(abi.encode(src, uint256(slot))))), bytes32(uint256(amt)));
        assertEq(ERC20(token).allowance(src, dst), amt, "wrong allowance");
    }
}
