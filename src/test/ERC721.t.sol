// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721} from "./utils/mocks/MockERC721.sol";
import {ERC721User} from "./utils/users/ERC721User.sol";

import {ERC721TokenReceiver} from "../tokens/ERC721.sol";

contract ERC721Recipient is ERC721TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

contract RevertingERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        revert("I_ALWAYS_REVERT");
    }
}

contract ERC721RecipientWithWrongReturnData is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        return 0xCAFEBEEF;
    }
}

contract NonERC721Recipient {}

contract ERC721Test is DSTestPlus {
    MockERC721 token;

    function setUp() public {
        token = new MockERC721("Token", "TKN");
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
    }

    function testMetadata(string memory name, string memory symbol) public {
        MockERC721 tkn = new MockERC721(name, symbol);

        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
    }

    function testMint(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(to), 1);
        assertEq(token.ownerOf(id), to);
    }

    function testBurn(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);
        token.burn(id);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(to), 0);
        assertEq(token.ownerOf(id), address(0));
    }

    function testApprove(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(address(this), id);

        token.approve(to, id);

        assertEq(token.getApproved(id), to);
    }

    function testApproveAll(
        address to,
        uint256 id,
        bool approved
    ) public {
        token.mint(address(this), id);

        token.setApprovalForAll(to, approved);

        assertBoolEq(token.isApprovedForAll(address(this), to), approved);
    }

    function testTransferFrom(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        ERC721User from = new ERC721User(token);

        token.mint(address(from), id);

        from.approve(address(this), id);

        token.transferFrom(address(from), to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), to);
        assertEq(token.balanceOf(to), 1);
        assertEq(token.balanceOf(address(from)), 0);
    }

    function testTransferFromSelf(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(address(this), id);

        token.transferFrom(address(this), to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), to);
        assertEq(token.balanceOf(to), 1);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testTransferFromApproveAll(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        ERC721User from = new ERC721User(token);

        token.mint(address(from), id);

        from.setApprovalForAll(address(this), true);

        token.transferFrom(address(from), to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), to);
        assertEq(token.balanceOf(to), 1);
        assertEq(token.balanceOf(address(from)), 0);
    }

    function testSafeTransferFromToEOA(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18) return; // Some precompiles cause reverts.

        if (to.code.length > 0) return;

        ERC721User from = new ERC721User(token);

        token.mint(address(from), id);

        from.setApprovalForAll(address(this), true);

        token.safeTransferFrom(address(from), to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), to);
        assertEq(token.balanceOf(to), 1);
        assertEq(token.balanceOf(address(from)), 0);
    }

    function testSafeTransferFromToERC721Recipient(uint256 id) public {
        ERC721User from = new ERC721User(token);
        ERC721Recipient recipient = new ERC721Recipient();

        token.mint(address(from), id);

        from.setApprovalForAll(address(this), true);

        token.safeTransferFrom(address(from), address(recipient), id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(address(from)), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), address(from));
        assertEq(recipient.id(), id);
        assertBytesEq(recipient.data(), "");
    }

    function testSafeTransferFromToERC721RecipientWithData(uint256 id, bytes calldata data) public {
        ERC721User from = new ERC721User(token);
        ERC721Recipient recipient = new ERC721Recipient();

        token.mint(address(from), id);

        from.setApprovalForAll(address(this), true);

        token.safeTransferFrom(address(from), address(recipient), id, data);

        assertEq(token.totalSupply(), 1);
        assertEq(token.getApproved(id), address(0));
        assertEq(token.ownerOf(id), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(address(from)), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), address(from));
        assertEq(recipient.id(), id);
        assertBytesEq(recipient.data(), data);
    }

    function testSafeMintToEOA(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18) return; // Some precompiles cause reverts.

        if (to.code.length > 0) return;

        token.safeMint(to, id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);
    }

    function testSafeMintToERC721Recipient(uint256 id) public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), id);

        assertEq(token.totalSupply(), 1);
        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), id);
        assertBytesEq(to.data(), "");
    }

    function testSafeMintToERC721RecipientWithData(uint256 id, bytes calldata data) public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), id, data);

        assertEq(token.totalSupply(), 1);
        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), id);
        assertBytesEq(to.data(), data);
    }

    function testFailMintToZero(uint256 id) public {
        token.mint(address(0), id);
    }

    function testFailDoubleMint(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);
        token.mint(to, id);
    }

    function testFailBurnUnMinted(uint256 id) public {
        token.burn(id);
    }

    function testFailDoubleBurn(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);

        token.burn(id);
        token.burn(id);
    }

    function testFailApproveUnMinted(uint256 id, address to) public {
        token.approve(to, id);
    }

    function testFailApproveUnAuthorized(
        address owner,
        uint256 id,
        address to
    ) public {
        if (owner == address(0)) to = address(0xBEEF);
        if (owner == address(this)) return;

        token.mint(owner, id);

        token.approve(to, id);
    }

    function testFailTransferFromUnOwned(
        address from,
        address to,
        uint256 id
    ) public {
        token.transferFrom(from, to, id);
    }

    function testFailTransferFromWrongFrom(
        address owner,
        address from,
        address to,
        uint256 id
    ) public {
        if (owner == address(0)) to = address(0xBEEF);
        if (from == owner) revert();

        token.mint(owner, id);

        token.transferFrom(from, to, id);
    }

    function testFailTransferFromToZero(uint256 id) public {
        token.mint(address(this), id);

        token.transferFrom(address(this), address(0), id);
    }

    function testFailTransferFromNotOwner(
        address from,
        address to,
        uint256 id
    ) public {
        if (from == address(0)) to = address(0xBEEF);

        token.mint(from, id);

        token.transferFrom(from, to, id);
    }

    function testFailSafeTransferFromToNonERC721Recipient(uint256 id) public {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new NonERC721Recipient()), id);
    }

    function testFailSafeTransferFromToNonERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new NonERC721Recipient()), id, data);
    }

    function testFailSafeTransferFromToRevertingERC721Recipient(uint256 id) public {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), id);
    }

    function testFailSafeTransferFromToRevertingERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), id, data);
    }

    function testFailSafeTransferFromToERC721RecipientWithWrongReturnData(uint256 id) public {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new ERC721RecipientWithWrongReturnData()), id);
    }

    function testFailSafeTransferFromToERC721RecipientWithWrongReturnDataWithData(uint256 id, bytes calldata data)
        public
    {
        token.mint(address(this), id);

        token.safeTransferFrom(address(this), address(new ERC721RecipientWithWrongReturnData()), id, data);
    }

    function testFailSafeMintToNonERC721Recipient(uint256 id) public {
        token.safeMint(address(new NonERC721Recipient()), id);
    }

    function testFailSafeMintToNonERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new NonERC721Recipient()), id, data);
    }

    function testFailSafeMintToRevertingERC721Recipient(uint256 id) public {
        token.safeMint(address(new RevertingERC721Recipient()), id);
    }

    function testFailSafeMintToRevertingERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new RevertingERC721Recipient()), id, data);
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnData(uint256 id) public {
        token.safeMint(address(new ERC721RecipientWithWrongReturnData()), id);
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnDataWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new ERC721RecipientWithWrongReturnData()), id, data);
    }
}

contract ERC721Invariants is DSTestPlus, DSInvariantTest {
    BalanceSum balanceSum;
    MockERC721 token;

    function setUp() public {
        token = new MockERC721("Token", "TKN");
        balanceSum = new BalanceSum(token);

        addTargetContract(address(balanceSum));
    }

    function invariantBalanceSum() public {
        assertEq(token.totalSupply(), balanceSum.sum());
    }
}

contract BalanceSum {
    MockERC721 token;
    uint256 public sum;

    constructor(MockERC721 _token) {
        token = _token;
    }

    function mint(address from, uint256 id) public {
        token.mint(from, id);
        sum++;
    }

    function burn(uint256 id) public {
        token.burn(id);
        sum--;
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
}
