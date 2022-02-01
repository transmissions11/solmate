// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";
import {SafeTransferLib} from "../utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

/// @notice Minimal ERC4646 tokenized vault implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/mixins/ERC4626.sol)
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

    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 amount, address to) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(amount)) != 0, "ZERO_SHARES");

        _mint(to, shares);

        emit Deposit(msg.sender, to, amount);

        asset.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function mint(uint256 shares, address to) public virtual returns (uint256 amount) {
        _mint(to, amount = previewMint(shares)); // No need to check for rounding error, previewMint rounds up.

        emit Deposit(msg.sender, to, amount);

        asset.safeTransferFrom(msg.sender, address(this), amount);

        afterDeposit(amount);
    }

    function withdraw(
        uint256 amount,
        address to,
        address from
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(amount); // No need to check for rounding error, previewWithdraw rounds up.

        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;

        _burn(from, shares); 

        emit Withdraw(from, to, amount);

        beforeWithdraw(amount);

        asset.safeTransfer(to, amount);
    }

    function redeem(
        uint256 shares,
        address to,
        address from
    ) public virtual returns (uint256 amount) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - shares;

        // Check for rounding error since we round down in previewRedeem.
        require((amount = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        _burn(from, shares);

        emit Withdraw(from, to, amount);

        beforeWithdraw(amount);

        asset.safeTransfer(to, amount);
    }

    /*///////////////////////////////////////////////////////////////
                           ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function assetsOf(address user) public view virtual returns (uint256) {
        return previewRedeem(balanceOf[user]);
    }

    function assetsPerShare() public view virtual returns (uint256) {
        return previewRedeem(10**decimals);
    }

    function previewDeposit(uint256 amount) public view virtual returns (uint256 shares) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? amount : amount.mulDivDown(totalSupply, totalAssets());
    }

    function previewMint(uint256 shares) public view virtual returns (uint256 amount) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), totalSupply);
    }

    function previewWithdraw(uint256 amount) public view virtual returns (uint256 shares) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? amount : amount.mulDivUp(totalSupply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256 amount) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), totalSupply);
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 amount) internal virtual {}

    function afterDeposit(uint256 amount) internal virtual {}
}
