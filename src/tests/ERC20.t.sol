// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.6;

import "ds-test/test.sol";
import "./utils/MockERC20.sol";
import "./utils/ERC20User.sol";

contract ERC20Test is DSTest {
    MockERC20 token;

    function setUp() public {
        token = new MockERC20("Token", "TKN", 18);
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

    function testMint(address usr, uint256 amt) public {
        token.mint(usr, amt);

        assertEq(token.totalSupply(), amt);
        assertEq(token.balanceOf(usr), amt);
    }

    function testBurn(
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

    function testApprove(address usr, uint256 amt) public {
        bool ret = token.approve(usr, amt);

        assertTrue(ret);
        assertEq(token.allowance(address(this), usr), amt);
    }

    function testTransfer(address usr, uint256 amt) public {
        token.mint(address(this), amt);

        bool ret = token.transfer(usr, amt);

        assertTrue(ret);
        assertEq(token.totalSupply(), amt);

        if (address(this) == usr) {
            assertEq(token.balanceOf(address(this)), amt);
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(usr), amt);
        }
    }

    function testTransferFrom(
        address dst,
        uint256 approval,
        uint256 amt
    ) public {
        if (amt > approval) return; // src must approve this for more than amt

        ERC20User src = new ERC20User(token);

        token.mint(address(src), amt);
        src.approve(address(this), approval);

        bool ret = token.transferFrom(address(src), dst, amt);

        assertTrue(ret);
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

    function testFailTransferFromInsufficientAllowance(
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

    function testFailTransferFromIsufficientBalance(
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

contract TestInvariants is DSTest {
    BalanceSum balanceSum;
    address[] targetContracts_;

    function targetContracts() public view returns (address[] memory) {
        return targetContracts_;
    }

    function setUp() public {
        balanceSum = new BalanceSum();
        targetContracts_.push(address(balanceSum));
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

    function approve(address dst, uint256 amt) external returns (bool) {
        return token.approve(dst, amt);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool) {
        return token.transferFrom(src, dst, amt);
    }
}
