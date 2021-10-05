// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {InvariantTest} from "./utils/InvariantTest.sol";
import {MockERC20} from "./utils/MockERC20.sol";
import {ERC20User} from "./utils/ERC20User.sol";

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
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        MockERC20 tkn = new MockERC20(name, symbol, decimals);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
        assertEq(tkn.decimals(), decimals);
    }

    function proveMint(address usr, uint256 amt) public {
        token.mint(usr, amt);

        assertEq(token.totalSupply(), amt);
        assertEq(token.balanceOf(usr), amt);
    }

    function proveBurn(
        address usr,
        uint256 amt0,
        uint256 amt1
    ) public {
        if (amt1 > amt0) return; // mint amount must exceed burn amount

        token.mint(usr, amt0);
        token.burn(usr, amt1);

        assertEq(token.totalSupply(), amt0 - amt1);
        assertEq(token.balanceOf(usr), amt0 - amt1);
    }

    function proveApprove(address usr, uint256 amt) public {
        assertTrue(token.approve(usr, amt));

        assertEq(token.allowance(address(this), usr), amt);
    }

    function proveTransfer(address usr, uint256 amt) public {
        token.mint(address(this), amt);

        assertTrue(token.transfer(usr, amt));
        assertEq(token.totalSupply(), amt);

        if (address(this) == usr) {
            assertEq(token.balanceOf(address(this)), amt);
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(usr), amt);
        }
    }

    function proveTransferFrom(
        address dst,
        uint256 approval,
        uint256 amt
    ) public {
        if (amt > approval) return; // src must approve this for more than amt

        ERC20User src = new ERC20User(token);

        token.mint(address(src), amt);

        src.approve(address(this), approval);

        assertTrue(token.transferFrom(address(src), dst, amt));
        assertEq(token.totalSupply(), amt);

        uint256 app = address(src) == address(this) || approval == type(uint256).max ? approval : approval - amt;
        assertEq(token.allowance(address(src), address(this)), app);

        if (address(src) == dst) {
            assertEq(token.balanceOf(address(src)), amt);
        } else {
            assertEq(token.balanceOf(address(src)), 0);
            assertEq(token.balanceOf(dst), amt);
        }
    }

    function proveFailTransferFromInsufficientAllowance(
        address dst,
        uint256 approval,
        uint256 amt
    ) public {
        require(approval < amt);

        ERC20User src = new ERC20User(token);

        token.mint(address(src), amt);
        src.approve(address(this), approval);
        token.transferFrom(address(src), dst, amt);
    }

    function proveFailTransferFromInsufficientBalance(
        address dst,
        uint256 mintAmt,
        uint256 sendAmt
    ) public {
        require(mintAmt < sendAmt);

        ERC20User src = new ERC20User(token);

        token.mint(address(src), mintAmt);
        src.approve(address(this), sendAmt);
        token.transferFrom(address(src), dst, sendAmt);
    }
}

contract ERC20Invariants is DSTestPlus, InvariantTest {
    BalanceSum balanceSum;

    function setUp() public {
        balanceSum = new BalanceSum();
        addTargetContract(address(balanceSum));
    }

    function invariantBalanceSum() public {
        assertEq(balanceSum.token().totalSupply(), balanceSum.sum());
    }
}

contract BalanceSum {
    MockERC20 public token = new MockERC20("Token", "TKN", 18);
    uint256 public sum;

    function mint(address usr, uint256 amt) external {
        token.mint(usr, amt);
        sum += amt;
    }

    function burn(address usr, uint256 amt) external {
        token.burn(usr, amt);
        sum -= amt;
    }

    function approve(address dst, uint256 amt) external {
        token.approve(dst, amt);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external {
        token.transferFrom(src, dst, amt);
    }

    function transfer(address dst, uint256 amt) external {
        token.transfer(dst, amt);
    }
}
