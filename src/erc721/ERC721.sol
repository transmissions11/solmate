// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC-721 + EIP-2612-like implementation.
// ! TO DO - add safeTransfer stuff 🙏
contract ERC721 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/
    
    string public name;
    
    string public symbol;
    
    /*///////////////////////////////////////////////////////////////
                             ERC-721 STORAGE
    //////////////////////////////////////////////////////////////*/
    
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(uint256 => address) public ownerOf;
    
    mapping(uint256 => string) public tokenURI;
    
    mapping(uint256 => address) public getApproved;
 
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    /*///////////////////////////////////////////////////////////////
                         PERMIT/EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/
    
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");
        
    bytes32 public immutable DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;
    
    constructor(
        string memory _name,
        string memory _symbol
    ) {
        name = _name;
        symbol = _symbol;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }
    
    /*///////////////////////////////////////////////////////////////
                              ERC-721 LOGIC
    //////////////////////////////////////////////////////////////*/
    
    function supportsInterface(bytes4 sig) external pure returns (bool) {
        return (sig == 0x80ac58cd || sig == 0x5b5e139f);
    }
    
    function approve(address spender, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");
        
        getApproved[tokenId] = spender;
        
        emit Approval(msg.sender, spender, tokenId); 
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transfer(address to, uint256 tokenId) external {
        require(msg.sender == ownerOf[tokenId], "NOT_OWNER");
        
        balanceOf[msg.sender]--; 
        
        balanceOf[to]++; 
        
        getApproved[tokenId] = address(0);
        
        ownerOf[tokenId] = to;
        
        emit Transfer(msg.sender, to, tokenId); 
    }
    
    function transferFrom(address, address to, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        
        require(
            msg.sender == owner || getApproved[tokenId] == msg.sender 
            || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED"
        );
        
        balanceOf[owner]--; 
        
        balanceOf[to]++;
        
        getApproved[tokenId] = address(0);
        
        ownerOf[tokenId] = to;
        
        emit Transfer(owner, to, tokenId); 
    }
    
    /*///////////////////////////////////////////////////////////////
                          PERMIT/EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        // This is reasonably safe because incrementing past type(uint256).max
        // through approvals is exceedingly unlikely!
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, tokenId, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_PERMIT_SIGNATURE");
            require(recoveredAddress == ownerOf[tokenId], "INVALID_OWNER");
        }

        getApproved[tokenId] = spender;

        emit Approval(owner, spender, tokenId);
    }
    
    /*///////////////////////////////////////////////////////////////
                          INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/
    
    function mint(address to, uint256 tokenId, string calldata _tokenURI) internal { 
        require(ownerOf[tokenId] == address(0), "TOKEN_ID_NOT_UNIQUE");
        
        totalSupply++;
        
        balanceOf[to]++;
        
        ownerOf[tokenId] = to;
        
        tokenURI[tokenId] = _tokenURI;
        
        emit Transfer(address(0), to, tokenId); 
    }
    
    function burn(address from, uint256 tokenId) internal { 
        require(ownerOf[tokenId] == from, "NOT_FROM_OWNER");
        
        totalSupply--;
        
        balanceOf[from]--;
        
        ownerOf[tokenId] = address(0);
        
        tokenURI[tokenId] = "";
        
        emit Transfer(from, address(0), tokenId); 
    }
}
