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
        MockERC721 tkn = new MockERC721(name, symbol, baseURI);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
        assertEq(tkn.baseURI(), baseURI);
    }

    function testMint(address usr, uint256 tokenId) public {
        token.mint(usr, tokenId);

        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(usr), 1);
        assertEq(token.ownerOf(tokenId), usr);
    }

    function testMintSameToken(address usr, uint256 tokenId) public {
        if (usr == address(0)) return;

        token.mint(usr, tokenId);

        try token.mint(usr, tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "ALREADY_MINTED");
        }
    }

    function testTokenURI(uint256 tokenId) public {
        assertBytesEq(bytes(token.tokenURI(tokenId)), abi.encodePacked(token.baseURI(), tokenId));
    }

    function testBurnInexistentToken(uint256 tokenId) public {
        try token.burn(tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "NOT_MINTED");
        }
    }

    function testBurn(
        address usr,
        uint256[] calldata tokenIds,
        uint8 burnCount 
    ) public {
        // tokens minted must exceed tokens burned
        if (tokenIds.length < burnCount || tokenIds.length == 0) return;
        if(usr == address(0)) return;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(usr, tokenIds[i]);
        }

        for (uint256 i = 0; i < burnCount; i++) {
            token.burn(tokenIds[i]);
        }

        assertEq(token.totalSupply(), tokenIds.length - burnCount);
        assertEq(token.balanceOf(usr), tokenIds.length - burnCount);
    }

    function testSafeTransferFromWithApprove(uint256 tokenId) public {
        ERC721User usr = new ERC721User(token);
        ERC721User receiver = new ERC721User(token);
        ERC721User operator = new ERC721User(token);

        // first mint a token
        token.mint(address(usr), tokenId);

        // The operator should not be able to transfer the unapproved token
        try operator.safeTransferFrom(address(usr), address(receiver), tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "NOT_APPROVED");
        }

        // then approve an operator for the token
        usr.approve(address(operator), tokenId);

        // The operator should be able to transfer the approved token
        operator.safeTransferFrom(address(usr), address(receiver), tokenId);
        assertEq(token.balanceOf(address(usr)), 0);
        assertEq(token.balanceOf(address(receiver)), 1);
        assertEq(token.ownerOf(tokenId), address(receiver));

        // The operator now should not be able to transfer the token again
        // since it was not approved by the current user
        try operator.safeTransferFrom(address(receiver), address(usr), tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "NOT_APPROVED");
        }
    }

    function testSafeTransferFromWithApproveForAll(uint256 tokenId) public {
        ERC721User usr = new ERC721User(token);
        ERC721User receiver = new ERC721User(token);
        ERC721User operator = new ERC721User(token);

        // first mint two tokens, only one will be approved
        token.mint(address(usr), tokenId);

        // The operator should not be able to transfer the unapproved token
        try operator.safeTransferFrom(address(usr), address(receiver), tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "NOT_APPROVED");
        }

        // then approve an operator
        usr.setApprovalForAll(address(operator), true);

        // The operator should be able to transfer any token from usr
        operator.safeTransferFrom(address(usr), address(receiver), tokenId);
        assertEq(token.balanceOf(address(usr)), 0);
        assertEq(token.balanceOf(address(receiver)), 1);
        assertEq(token.ownerOf(tokenId), address(receiver));

        // The operator now should not be able to transfer the token 
        // since it was not approved by the current user
        try operator.safeTransferFrom(address(receiver), address(usr), tokenId) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "NOT_APPROVED");
        }
    }

    function testTransfer(address usr, uint256 tokenId) public {
        token.mint(address(this), tokenId);

        assertTrue(token.transfer(usr, tokenId));
        assertEq(token.totalSupply(), 1);

        if (address(this) == usr) {
            assertEq(token.balanceOf(address(this)), 1);
            assertEq(token.ownerOf(tokenId), address(this));
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(usr), 1);
            assertEq(token.ownerOf(tokenId), usr);
        }
    }
}
