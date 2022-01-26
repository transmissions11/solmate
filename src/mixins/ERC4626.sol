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

    event Deposit(address indexed from, address indexed to, uint256 amount);

    event Withdraw(address indexed from, address indexed to, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                                IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable underlying;

    uint256 internal immutable SCALAR;

    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _underlying.decimals()) {
        underlying = _underlying;

        SCALAR = 10**decimals;
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(address to, uint256 amount) public virtual returns (uint256 shares) {
        shares = previewDeposit(amount);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount);

        underlying.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function mint(address to, uint256 shares) public virtual returns (uint256 amount) {
        amount = previewMint(shares);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount);

        underlying.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function withdraw(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (uint256 shares) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;

        shares = previewMint(amount);

        _burn(from, shares);

        emit Withdraw(from, to, amount);

        beforeWithdraw(amount);

        underlying.safeTransfer(to, amount);
    }

    function redeem(
        address from,
        address to,
        uint256 shares
    ) public virtual returns (uint256 amount) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;

        amount = previewRedeem(shares);

        _burn(from, shares);

        emit Withdraw(from, to, amount);

        beforeWithdraw(amount);

        underlying.safeTransfer(to, amount);
    }

    /*///////////////////////////////////////////////////////////////
                        VAULT ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalUnderlying() public view virtual returns (uint256);

    function balanceOfUnderlying(address user) public view virtual returns (uint256) {
        return previewRedeem(balanceOf[user]);
    }

    function exchangeRate() public view returns (uint256) {
        return previewRedeem(SCALAR);
    }

    function previewDeposit(uint256 amount) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        // TODO: what do we do about the intermediate exchange rate? do we do it up? can we get rid of it?
        return supply == 0 ? SCALAR : amount.fmul(totalSupply.fdiv(totalUnderlying(), SCALAR), SCALAR);
    }

    function previewMint(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        // TODO: what do we do about the intermediate exchange rate? do we do it up? can we get rid of it?
        return supply == 0 ? SCALAR : shares.fmulUp(totalUnderlying().fdiv(totalSupply, SCALAR), SCALAR);
    }

    function previewWithdraw(uint256 amount) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        // TODO: what do we do about the intermediate exchange rate? do we do it up? can we get rid of it?
        // TODO: do we even have an intermediate? what if we did (amount *underlying) / supply
        return supply == 0 ? SCALAR : amount.fmulUp(totalUnderlying().fdiv(totalSupply, SCALAR), SCALAR);
    }

    function previewRedeem(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        // TODO: what do we do about the intermediate exchange rate? do we do it up? can we get rid of it?
        return supply == 0 ? SCALAR : shares.fmul(totalUnderlying().fdiv(totalSupply, SCALAR), SCALAR);
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 amount) internal virtual {}

    function afterDeposit(uint256 amount) internal virtual {}
}
