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

    function deposit(uint256 amount, address to) public virtual returns (uint256 shares) {
        shares = previewDeposit(amount);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount);

        underlying.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function mint(uint256 shares, address to) public virtual returns (uint256 amount) {
        amount = previewMint(shares);

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount);

        underlying.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function withdraw(
        uint256 amount,
        address to,
        address from
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
        uint256 shares,
        address to,
        address from
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

    function totalAssets() public view virtual returns (uint256);

    function assetsOf(address user) public view virtual returns (uint256) {
        return previewRedeem(balanceOf[user]);
    }

    function assetsPerShare() public view returns (uint256) {
        return previewRedeem(SCALAR);
    }

    function previewDeposit(uint256 amount) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? SCALAR : amount.mulDiv(totalSupply, totalAssets());
    }

    function previewMint(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? SCALAR : shares.mulDivUp(totalAssets(), totalSupply);
    }

    function previewWithdraw(uint256 amount) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? SCALAR : amount.mulDivUp(totalSupply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? SCALAR : shares.mulDiv(totalAssets(), totalSupply);
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 amount) internal virtual {}

    function afterDeposit(uint256 amount) internal virtual {}
}
