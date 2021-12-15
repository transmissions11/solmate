// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721} from "./utils/mocks/MockERC721.sol";
import {ERC721User} from "./utils/users/ERC721User.sol";

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

    function proveMint(address usr, uint256 tokenId) public {
        token.mint(usr, tokenId);

        assertEq(token.totalSupply(), tokenId);
        assertEq(token.balanceOf(usr), tokenId);
    }

    function proveBurn(
        address usr,
        uint256[] tokenIds0,
        uint256[] tokenIds1
    ) public {
        // tokens minted must exceed tokens burned
        if (tokenIds1.length > tokenIds0.length) return;

        for (uint256 i = 0; i < tokenIds1.length; i++) {
            token.mint(usr, tokenId1s[i]);
        }

        for (uint256 i = 0; i < tokenIds0; i++) {
            token.burn(usr, tokenIds0[i]);
        }

        assertEq(token.totalSupply(), tokenIds0.length - tokenIds1.length);
        assertEq(token.balanceOf(usr), tokenIds0.length - tokenIds1.length);
    }

    function proveApprove(address usr, uint256 tokenId) public {
        assertTrue(token.approve(usr, tokenId));

        assertEq(token.isApprovedForAll(self, usr), tokenId);
    }

    function proveTransfer(address usr, uint256 tokenId) public {
        token.mint(self, tokenId);

        assertTrue(token.transfer(usr, tokenId));
        assertEq(token.totalSupply(), tokenId);

        if (self == usr) {
            assertEq(token.balanceOf(self), tokenId);
        } else {
            assertEq(token.balanceOf(self), 0);
            assertEq(token.balanceOf(usr), tokenId);
        }
    }

    function proveTransferFrom(
        address dst,
        uint256[] approvals,
        uint256[] tokenIds
    ) public {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            src.approve(self, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertTrue(token.transferFrom(address(src), dst, tokenIds[i]));
        }

        assertEq(token.totalSupply(), tokenIds);

        uint256 app = address(src) == self || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        assertEq(token.allowance(address(src), self), app);

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
        uint256[] approvals,
        uint256[] tokenIds
    ) {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            src.approve(self, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertTrue(token.safeTransferFrom(address(src), dst, tokenIds[i]));
        }

        assertEq(token.totalSupply(), tokenIds);

        uint256 app = address(src) == self || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        assertEq(token.allowance(address(src), self), app);

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
        uint256[] approvals,
        uint256[] tokenIds,
        bytes memory data
    ) {
        // dst must approve this for more than tokenIds.length
        if (tokenIds.length > approvals.length) return;

        ERC721User src = new ERC721User(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.mint(address(src), tokenIds[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            src.approve(self, approvals[i]);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertTrue(token.safeTransferFrom(address(src), dst, tokenIds[i], data));
        }

        assertEq(token.totalSupply(), tokenIds);

        uint256 app = address(src) == self || approvals == type(uint256).max ? approvals : approvals - tokenIds;
        assertEq(token.allowance(address(src), self), app);

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
