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

    function testApprove(address usr, uint256 tokenId) public {
        //assertTrue(token.approve(usr, tokenId));

        //assertEq(token.isApprovedForAll(msg.sender, usr, tokenId));
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

    function testTransferFrom(
        address dst,
        uint256[] calldata tokenIds,
        uint8 approvalCount
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length < approvalCount) return;
        if(dst == address(0)) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < approvalCount; i++) {
            src.approve(address(this), tokenIds[i]);
            token.transferFrom(address(src), dst, tokenIds[i]);
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        } else {
            assertEq(token.balanceOf(address(src)), tokenIds.length - approvalCount);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if(i < approvalCount)
                    assertEq(token.ownerOf(tokenIds[i]), dst);
                else
                    assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        }
    }

    function testSafeTransferFrom(
        address dst,
        uint256[] calldata tokenIds,
        uint8 approvalCount
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length < approvalCount) return;
        if(dst == address(0)) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < approvalCount; i++) {
            src.approve(address(this), tokenIds[i]);
            token.safeTransferFrom(address(src), dst, tokenIds[i]);
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        } else {
            assertEq(token.balanceOf(address(src)), tokenIds.length - approvalCount);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if(i < approvalCount)
                    assertEq(token.ownerOf(tokenIds[i]), dst);
                else
                    assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        }
    }

    function testSafeTransferFrom(
        address dst,
        uint256[] calldata tokenIds,
        uint8 approvalCount,
        bytes memory data
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length < approvalCount) return;
        if(dst == address(0)) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < approvalCount; i++) {
            src.approve(address(this), tokenIds[i]);
            token.safeTransferFrom(address(src), dst, tokenIds[i], data);
        }

        assertEq(token.totalSupply(), tokenIds.length);

        //uint256 app = address(src) == msg.sender || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        //assertEq(token.allowance(address(src), msg.sender), app);

        if (address(src) == dst) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        } else {
            assertEq(token.balanceOf(address(src)), tokenIds.length - approvalCount);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if(i < approvalCount)
                    assertEq(token.ownerOf(tokenIds[i]), dst);
                else
                    assertEq(token.ownerOf(tokenIds[i]), address(src));
            }
        }
    }
}
