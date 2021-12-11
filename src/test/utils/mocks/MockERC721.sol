// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "../../../tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(
        address to,
        uint256 tokenId,
        string calldata tokenURI
    ) external {
        _mint(to, tokenId, tokenURI);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}
