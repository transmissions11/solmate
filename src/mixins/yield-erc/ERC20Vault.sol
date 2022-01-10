// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "../../tokens/ERC20.sol";
import {FixedPointMathLib} from "../../utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "../../utils/SafeTransferLib.sol";

/// @title Yield Bearing Vault
/// @author joeysantoro, Transmissions11 and JetJadeja
contract ERC4626Vault is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*///////////////////////////////////////////////////////////////
                                IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The underlying token the Vault accepts.
    ERC20 public immutable underlying;

    /// @notice The base unit of the underlying token and hence vault.
    /// @dev Equal to 10 ** decimals. Used for fixed point arithmetic.
    uint256 public immutable baseUnit;

    /// @notice Creates a new Vault that accepts a specific underlying token.
    /// @param _underlying The ERC20 compliant token the Vault should accept.
    /// @param _name The name for the vault token.
    /// @param _symbol The symbol for the vault token.

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    )
        ERC20(
            _name,
            _symbol,
            _underlying.decimals()
        )
    {
        underlying = _underlying;

        baseUnit = 10**decimals;
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted after a successful deposit.
    /// @param from The address that deposited into the Vault.
    /// @param to The address that received deposit shares.
    /// @param underlyingAmount The amount of underlying tokens that were deposited.
    event Deposit(address indexed from, address indexed to, uint256 underlyingAmount);

    /// @notice Emitted after a successful withdrawal.
    /// @param from The address that withdrew from the Vault.
    /// @param to The destination for withdrawn tokens.
    /// @param underlyingAmount The amount of underlying tokens that were withdrawn.
    event Withdraw(address indexed from, address indexed to, uint256 underlyingAmount);

    /// @notice Deposit a specific amount of underlying tokens.
    /// @param to The address to receive shares corresponding to the deposit
    /// @param underlyingAmount The amount of the underlying token to deposit.
    function deposit(address to, uint256 underlyingAmount) external virtual returns (uint256 shares) {
        shares = underlyingAmount.fdiv(exchangeRate(), baseUnit);
        // Determine the equivalent amount of shares and mint them.
        _mint(to, shares);

        emit Deposit(msg.sender, to, underlyingAmount);

        // Transfer in underlying tokens from the user.
        // This will revert if the user does not have the amount specified.
        underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);

        afterDeposit(underlyingAmount);
    }

    /// @notice Withdraw a specific amount of underlying tokens.
    /// @param to The address to receive underlying tokens corresponding to the withdrawal.
    /// @param underlyingAmount The amount of underlying tokens to withdraw.
    function withdraw(address to, uint256 underlyingAmount) external virtual returns (uint256 shares) {
        shares = underlyingAmount.fdiv(exchangeRate(), baseUnit);

        // Determine the equivalent amount of shares and burn them.
        // This will revert if the user does not have enough shares.
        _burn(msg.sender, shares);

        emit Withdraw(msg.sender, to, underlyingAmount);

        // Withdraw from strategies if needed and transfer.
        beforeWithdraw(underlyingAmount);

        underlying.safeTransfer(to, underlyingAmount);
    }

    /// @notice Redeem a specific amount of shares for underlying tokens.
    /// @param to The address to receive underlying tokens corresponding to the withdrawal.
    /// @param shareAmount The amount of shares to redeem for underlying tokens.
    function redeem(address to, uint256 shareAmount) external virtual returns (uint256 underlyingAmount) {

        // Determine the equivalent amount of underlying tokens.
        underlyingAmount = shareAmount.fmul(exchangeRate(), baseUnit);

        // Burn the provided amount of shares.
        // This will revert if the user does not have enough shares.
        _burn(msg.sender, shareAmount);

        emit Withdraw(msg.sender, to, underlyingAmount);

        // Withdraw from strategies if needed and transfer.
        beforeWithdraw(underlyingAmount);

        underlying.safeTransfer(to, underlyingAmount);
    }

    function beforeWithdraw(uint256 underlyingAmount) internal virtual {}

    function afterDeposit(uint256 underlyingAmount) internal virtual {}

    /*///////////////////////////////////////////////////////////////
                        VAULT ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns a user's Vault balance in underlying tokens.
    /// @param user The user to get the underlying balance of.
    /// @return The user's Vault balance in underlying tokens.
    function balanceOfUnderlying(address user) external view returns (uint256) {
        return balanceOf[user].fmul(exchangeRate(), baseUnit);
    }

    /// @notice Returns the amount of underlying tokens a share can be redeemed for.
    /// @return The amount of underlying tokens a share can be redeemed for.
    function exchangeRate() public view returns (uint256) {
        // Get the total supply of shares.
        uint256 shareSupply = totalSupply;

        // If there are no shares in circulation, return an exchange rate of 1:1.
        if (shareSupply == 0) return baseUnit;

        // Calculate the exchange rate by dividing the total holdings by the share supply.
        return totalHoldings().fdiv(shareSupply, baseUnit);
    }

    /// @notice Calculates the total amount of underlying tokens the Vault holds.
    /// @return totalUnderlyingHeld The total amount of underlying tokens the Vault holds.
    function totalHoldings() public view virtual returns (uint256) {
        return underlying.balanceOf(address(this));
    }
}
