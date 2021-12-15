// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "../../../tokens/ERC721.sol";

contract ERC721User {
    ERC721 token;

    constructor(ERC721 _token) {
        token = _token;
    }

    function supportsInterface(bytes4 interfaceId) external view {
        token.supportsInterface(interfaceId);
    }

    function approve(address spender, uint256 tokenId) external {
        token.approve(spender, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        token.setApprovalForAll(operator, approved);
    }

    function transfer(address to, uint256 tokenId) external {
        token.transfer(to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        token.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        token.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        token.safeTransferFrom(from, to, tokenId, data);
    }
}
