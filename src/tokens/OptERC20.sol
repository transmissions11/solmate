// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract OptERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string internal name;

    string internal symbol;

    uint8 internal immutable decimals;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal totalSupply;

    mapping(address => uint256) internal balanceOf;

    mapping(address => mapping(address => uint256)) internal allowance;

    /*///////////////////////////////////////////////////////////////
                             delegation logic
    //////////////////////////////////////////////////////////////*/

    address internal immutable erc20Impl;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _erc20Impl
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        erc20Impl = _erc20Impl;
    }

    fallback() external {
        bytes4 sig;
        assembly {
            calldatacopy(0, 0, 4)
            sig := mload(0)
        }

        // check if calling transfer
        if(sig == bytes4(0xa9059cbb)) {
            address to;
            uint amount;
            assembly {
                calldatacopy(0, 4, 32)
                to := mload(0)

                calldatacopy(0, 36, 32)
                amount := mload(0)
            }

            balanceOf[msg.sender] -= amount;

            // Cannot overflow because the sum of all user
            // balances can't exceed the max uint256 value.
            unchecked {
                balanceOf[to] += amount;
            }

            emit Transfer(msg.sender, to, amount);

            assembly {
                mstore(0, 1)
                return (0, 32)
            }
        }

        address impl = erc20Impl;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }    
}

