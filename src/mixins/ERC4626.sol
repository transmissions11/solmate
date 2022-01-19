// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "../tokens/ERC20.sol";
import {SafeTransferLib} from "../utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

/// @notice Minimal ERC4646 tokenized vault implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/mixinz/ERC4626.sol)
abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*///////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed from, address indexed to, uint256 underlyingAmount);

    event Withdraw(address indexed from, address indexed to, uint256 underlyingAmount);

    /*///////////////////////////////////////////////////////////////
                                IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The underlying token the vault accepts.
    ERC20 public immutable underlying;

    /// @notice The base unit of the underlying token and hence vault.
    /// @dev Equal to 10 ** decimals. Used for fixed point arithmetic.
    uint256 internal immutable baseUnit;

    /// @notice Creates a new vault that accepts a specific underlying token.
    /// @param _underlying The ERC20 compliant token the vault should accept.
    /// @param _name The name for the vault token.
    /// @param _symbol The symbol for the vault token.

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _underlying.decimals()) {
        underlying = _underlying;

        baseUnit = 10**decimals;
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(address to, uint256 underlyingAmount) public virtual returns (uint256 shares) {
        _mint(to, shares = calculateShares(underlyingAmount));

        emit Deposit(msg.sender, to, underlyingAmount);

        underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);

        afterDeposit(underlyingAmount);
    }

    function mint(address to, uint256 shareAmount) public virtual returns (uint256 underlyingAmount) {
        underlyingAmount = calculateUnderlying(shareAmount);
        
        _mint(to, shareAmount);

        emit Deposit(msg.sender, to, underlyingAmount);

        underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);

        afterDeposit(underlyingAmount);
    }

    function withdraw(address from, address to, uint256 underlyingAmount) public virtual returns (uint256 shares) {
        shares = calculateShares(underlyingAmount);

        if (msg.sender != from && allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= shares;
        }
        
        _burn(from, shares);

        emit Withdraw(from, to, underlyingAmount);

        beforeWithdraw(underlyingAmount);

        underlying.safeTransfer(to, underlyingAmount);
    }

    function redeem(address from, address to, uint256 shareAmount) public virtual returns (uint256 underlyingAmount) {
        if (msg.sender != from && allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= shareAmount;
        }

        underlyingAmount = calculateUnderlying(shareAmount);

        _burn(from, shareAmount);

        emit Withdraw(from, to, underlyingAmount);

        beforeWithdraw(underlyingAmount);

        underlying.safeTransfer(to, underlyingAmount);
    }

    function beforeWithdraw(uint256 underlyingAmount) internal virtual {}

    function afterDeposit(uint256 underlyingAmount) internal virtual {}

    /*///////////////////////////////////////////////////////////////
                        VAULT ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalUnderlying() public view virtual returns (uint256) {
        return underlying.balanceOf(address(this));
    }

    function balanceOfUnderlying(address user) public view virtual returns (uint256) {
        return calculateUnderlying(balanceOf[user]);
    }

    function calculateShares(uint256 underlyingAmount) public view virtual returns (uint256) {
        uint256 shareSupply = totalSupply;

        if (shareSupply == 0) return underlyingAmount;

        uint256 exchangeRate = totalUnderlying().fdiv(shareSupply, baseUnit);

        return underlyingAmount.fdiv(exchangeRate, baseUnit);
    }

    function calculateUnderlying(uint256 shareAmount) public view virtual returns (uint256) {
        uint256 shareSupply = totalSupply;
        
        if (shareSupply == 0) return shareAmount;

        uint256 exchangeRate = totalUnderlying().fdiv(shareSupply, baseUnit);

        return shareAmount.fmulUp(exchangeRate, baseUnit);
    }
}
