// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

/// @notice Abstract ERC20 interface with metadata.
interface ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*///////////////////////////////////////////////////////////////
                                 METADATA
    //////////////////////////////////////////////////////////////*/

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function decimals() external view returns (uint8);

    /*///////////////////////////////////////////////////////////////
                               ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address to,
        address from,
        uint256 value
    ) external returns (bool);
}
