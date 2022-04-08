// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a single owner auth pattern.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Ownable.sol)
/// @author Modified from BoringSolidity (https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/BoringOwnable.sol)
abstract contract Ownable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event SetOwner(address indexed from, address indexed to);

    event SetPendingOwner(address indexed from, address indexed to);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    address public pendingOwner;

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit SetOwner(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function claimOwner() public virtual {
        require(msg.sender == pendingOwner, "NOT_PENDING_OWNER");

        emit SetOwner(owner, msg.sender);

        delete pendingOwner;

        owner = msg.sender;
    }

    function setOwner(address to, bool direct) public virtual onlyOwner {
        if (direct) {
            owner = to;

            emit SetOwner(msg.sender, to);
        } else {
            pendingOwner = to;

            emit SetPendingOwner(msg.sender, to);
        }
    }
}
