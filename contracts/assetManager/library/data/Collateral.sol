// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library Collateral {
    enum Kind {
        VAULT, // vault collateral (tokens in in agent vault)
        POOL, // pool collateral (NAT)
        //@note An Agent's stake in the POOL (in NAT)
        //@note the amount of NAT an Agent has staked in the backstop pool
        AGENT_POOL // agent's pool tokens (expressed in NAT) - only important for minting

    }

    struct Data {
        Kind kind;
        uint256 fullCollateral;
        uint256 amgToTokenWeiPrice;
    }

    struct CombinedData {
        Collateral.Data agentCollateral;
        Collateral.Data poolCollateral;
        Collateral.Data agentPoolTokens;
    }
}
