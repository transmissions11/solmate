// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721} from "./utils/mocks/MockERC721.sol";
import {ERC721User} from "./utils/users/ERC721User.sol";

contract ERC721Test is DSTestPlus {
    MockERC721 token;

    function setUp() public {
        token = new MockERC721("Token", "TKN", "ipfs://somehash/");
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.baseURI(), "ipfs://somehash/");
    }

    function testMetadata(string memory name, string memory symbol, string memory baseURI) public {
        MockERC721 tkn = new MockERC721(name, symbol);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
        assertEq(tkn.baseURI(), baseURI);
    }

    function proveMint(address usr, uint256 tokenId) public {
        token.mint(usr, tokenId);

        assertEq(token.totalSupply(), tokenId);
        assertEq(token.balanceOf(usr), tokenId);
    }

    function proveTokenURI(address usr, uint256 tokenId) public {
        token.mint(usr, tokenId);

        assertEq(token.tokenURI(tokenId), abi.encodePacked(token.baseURI(), tokenURI(tokenId)));
    }

    function proveBurn(
        address usr,
        uint256[] calldata tokenIds0,
        uint256[] calldata tokenIds1
    ) public {
        // tokens minted must exceed tokens burned
        if (tokenIds1.length > tokenIds0.length) return;

        for (uint256 i = 0; i < tokenIds1.length; i++) {
            token.mint(usr, tokenIds1[i]);
        }

        for (uint256 i = 0; i < tokenIds0.length; i++) {
            token.burn(tokenIds0[i]);
        }

        assertEq(token.totalSupply(), tokenIds0.length - tokenIds1.length);
        assertEq(token.balanceOf(usr), tokenIds0.length - tokenIds1.length);
    }

    function proveApprove(address usr, uint256 tokenId) public {
        //assertTrue(token.approve(usr, tokenId));

        //assertEq(token.isApprovedForAll(msg.sender, usr, tokenId));
    }

    function proveTransfer(address usr, uint256 tokenId) public {
        token.mint(msg.sender, tokenId);

        assertTrue(token.transfer(usr, tokenId));
        assertEq(token.totalSupply(), tokenId);

        if (msg.sender == usr) {
            assertEq(token.balanceOf(msg.sender), tokenId);
        } else {
            assertEq(token.balanceOf(msg.sender), 0);
            assertEq(token.balanceOf(usr), tokenId);
        }
    }

    function proveTransferFrom(
        address dst,
        uint256[] calldata approvals,
        uint256[] calldata tokenIds
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.approve(msg.sender, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            //assertTrue(token.transferFrom(address(src), dst, tokenIds[i]));
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(address(src)), tokenIds[i]);
            }
        } else {
            assertEq(token.balanceOf(address(src)), 0);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(dst), tokenIds[i]);
            }
        }
    }

    function proveSafeTransferFrom(
        address dst,
        uint256[] calldata approvals,
        uint256[] calldata tokenIds
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            src.approve(msg.sender, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            //assertTrue(token.safeTransferFrom(address(src), dst, tokenIds[i]));
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(address(src)), tokenIds[i]);
            }
        } else {
            assertEq(token.balanceOf(address(src)), 0);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(dst), tokenIds[i]);
            }
        }
    }

    function proveSafeTransferFrom(
        address dst,
        uint256[] calldata approvals,
        uint256[] calldata tokenIds,
        bytes memory data
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            src.approve(msg.sender, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            //assertTrue(token.safeTransferFrom(address(src), dst, tokenIds[i], data));
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(address(src)), tokenIds[i]);
            }
        } else {
            assertEq(token.balanceOf(address(src)), 0);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.balanceOf(dst), tokenIds[i]);
            }
        }
    }
}
