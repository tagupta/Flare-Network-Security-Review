// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * Core vault settings
 */
interface ICoreVaultClientSettings {
    //@note sets the address of the manager of the core vault. This address is more like admin of core vault
    function setCoreVaultManager(address _coreVaultManager) external;
    //@note sets the address on the underlying chain where the vault's funds are actually held
    function setCoreVaultNativeAddress(address payable _nativeAddress) external;
    //@note Adds extra time to transaction deadlines. If a transfer is slow, this grace period prevents it from being marked as failed too quickly.
    function setCoreVaultTransferTimeExtensionSeconds(uint256 _transferTimeExtensionSeconds) external;
    //@note Sets the fee users pay when they redeem their FAssets.
    // BIPS means "Basis Points" (1/100th of a percent). E.g., 50 BIPS = a 0.5% fee.
    function setCoreVaultRedemptionFeeBIPS(uint256 _redemptionFeeBIPS) external;
    //@note this dictates the minimum percentage of funds that must always remain in the core vault after transfer to agent's or user's underlying address
    function setCoreVaultMinimumAmountLeftBIPS(uint256 _minimumAmountLeftBIPS) external;
    //@note Sets the minimum amount a user must redeem at once. This prevents users from spamming the network with tiny, unprofitable redemption requests.
    function setCoreVaultMinimumRedeemLots(uint256 _minimumRedeemLots) external;

    function getCoreVaultManager() external view returns (address);

    function getCoreVaultNativeAddress() external view returns (address);

    function getCoreVaultTransferTimeExtensionSeconds() external view returns (uint256);

    function getCoreVaultRedemptionFeeBIPS() external view returns (uint256);

    function getCoreVaultMinimumAmountLeftBIPS() external view returns (uint256);

    function getCoreVaultMinimumRedeemLots() external view returns (uint256);
}
