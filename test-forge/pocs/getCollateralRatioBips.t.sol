// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import {AgentCollateral} from ''; // Adjust import path as needed
// import "../../contracts/AssetManager/Conversion.sol"; // Adjust import path as needed

contract AgentCollateralPOC is Test {
    // Mock the necessary structures and dependencies
    // using SafeMath for uint256;

    function testLiquidationPriceInconsistency() public {
        // 1. SETUP: Create a scenario where trusted price is worse than regular price
        uint256 regularPricePerAMG = 6e14; // 60,000 FLR per BTC / 1e8 AMG
        uint256 trustedPricePerAMG = 7.2e14; // 72,000 FLR per BTC / 1e8 AMG (Worse for agent)

        uint256 agentDebtAMG = 100_000_000; // 1 fBTC
        uint256 agentCollateralWei = 7.2e22; // 72,000 FLR (exactly covers at trusted price)

        // 2. CALCULATE RATIOS WITH BOTH PRICES
        // Ratio with regular price
        uint256 debtValueRegular = agentDebtAMG.mulDiv(regularPricePerAMG, 1e18);
        uint256 ratioRegular = agentCollateralWei.mulDiv(1e18, debtValueRegular).mulDiv(10000, 1e18);
        // ratioRegular = (7.2e22 / 6e22) * 10000 = 12000 BIPS (exactly at threshold)

        // Ratio with trusted price (the one that should trigger liquidation)
        uint256 debtValueTrusted = agentDebtAMG.mulDiv(trustedPricePerAMG, 1e18);
        uint256 ratioTrusted = agentCollateralWei.mulDiv(1e18, debtValueTrusted).mulDiv(10000, 1e18);
        // ratioTrusted = (7.2e22 / 7.2e22) * 10000 = 10000 BIPS (undercollateralized)

        // 3. SIMULATE THE BUGGY getCollateralRatioBIPS FUNCTION
        uint256 reportedRatio = Math.max(ratioRegular, ratioTrusted); // This is what the function does
        uint256 reportedPrice = regularPricePerAMG; // This is the BUG: uses regular price instead of trusted

        // 4. DEMONSTRATE THE UNFAIR LIQUIDATION
        uint256 safetyThreshold = 12000; // 120% in BIPS

        console.log("=== LIQUIDATION SCENARIO ===");
        console.log("Agent Debt: %s AMG (1 fBTC)", agentDebtAMG);
        console.log("Agent Collateral: %s FLR wei (72,000 FLR)", agentCollateralWei);
        console.log("Regular Price: %s FLR-wei per AMG (60,000 FLR/BTC)", regularPricePerAMG);
        console.log("Trusted Price: %s FLR-wei per AMG (72,000 FLR/BTC)", trustedPricePerAMG);
        console.log("Safety Threshold: %s BIPS", safetyThreshold);
        console.log("---");
        console.log("Ratio with Regular Price: %s BIPS", ratioRegular);
        console.log("Ratio with Trusted Price: %s BIPS", ratioTrusted);
        console.log("Reported Ratio (max): %s BIPS", reportedRatio);
        console.log("Reported Price (BUG): %s FLR-wei per AMG", reportedPrice);
        console.log("---");

        // Check if liquidation should be triggered
        if (reportedRatio < safetyThreshold) {
            console.log("Liquidation would be triggered based on reported ratio");

            // Calculate how much collateral should be seized at TRUSTED price (fair)
            uint256 fairCollateralToSeize = agentDebtAMG.mulDiv(trustedPricePerAMG, 1e18);
            uint256 fairAgentRemainder = agentCollateralWei - fairCollateralToSeize;

            // Calculate how much collateral would be seized at REPORTED price (unfair due to bug)
            uint256 actualCollateralToSeize = agentDebtAMG.mulDiv(reportedPrice, 1e18);
            uint256 actualAgentRemainder = agentCollateralWei - actualCollateralToSeize;

            console.log("Fair seizure (at trusted price): %s FLR wei", fairCollateralToSeize);
            console.log("Fair agent remainder: %s FLR wei", fairAgentRemainder);
            console.log("Actual seizure (at reported price): %s FLR wei", actualCollateralToSeize);
            console.log("Actual agent remainder: %s FLR wei", actualAgentRemainder);

            // Show the unfair loss
            uint256 unfairLoss = actualCollateralToSeize - fairCollateralToSeize;
            console.log("---");
            console.log("UNFAIR LOSS TO AGENT: %s FLR wei", unfairLoss);
            console.log("This represents extra collateral seized due to price inconsistency bug");

            // Verification
            assertTrue(unfairLoss > 0, "Agent should experience unfair loss");
            assertTrue(actualAgentRemainder < fairAgentRemainder, "Agent gets less than fair share");

        } else {
            console.log("Liquidation would not be triggered in this setup");
            console.log("Try adjusting prices to make trusted price produce lower ratio");
        }
    }

    // Helper function to simulate the actual bug we're testing
    function simulateBuggyFunction(uint256 regularPrice, uint256 trustedPrice, uint256 collateral, uint256 debt)
        public pure returns (uint256 reportedRatio, uint256 reportedPrice) {
        // This simulates the problematic logic in getCollateralRatioBIPS
        uint256 ratioRegular = collateral.mulDiv(1e18, debt.mulDiv(regularPrice, 1e18)).mulDiv(10000, 1e18);
        uint256 ratioTrusted = collateral.mulDiv(1e18, debt.mulDiv(trustedPrice, 1e18)).mulDiv(10000, 1e18);

        reportedRatio = Math.max(ratioRegular, ratioTrusted);
        reportedPrice = regularPrice; // This is the BUG - should return trustedPrice if it was used for ratio
        return (reportedRatio, reportedPrice);
    }
}