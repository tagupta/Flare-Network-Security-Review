// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

//@note The "bot" is a piece of automated software run by (or on behalf of) the owner of an Agent Vault. Its job is to perform routine maintenance tasks for the vault, such as:
//Processing redemption requests.
//Monitoring collateral ratios.
//Topping up vault funds.
//Responding to system events.
interface IAgentPing {
    /**
     * Agent bot liveness check.
     * @param agentVault the agent vault whose owner bot to ping
     * @param sender the account that triggered ping; helps bot decide whether it is important to answer
     * @param query off-chain defined id of the query
     */
    event AgentPing(address indexed agentVault, address indexed sender, uint256 query);

    /**
     * Response to agent bot liveness check.
     * @param agentVault the pinged agent vault
     * @param owner owner of the agent vault (management address)
     * @param query repeated `query` from the AgentPing event
     * @param response response data to the query
     */
    event AgentPingResponse(address indexed agentVault, address indexed owner, uint256 query, string response);

    /**
     * Used for liveness checks, simply emits AgentPing event.
     * @param _agentVault the agent vault whose owner bot to ping
     * @param _query off-chain defined id of the query
     */
    //@note Who can call this function
    // A monitoring service.
    // A concerned user.
    // Another smart contract in the system doing a periodic check.
    function agentPing(address _agentVault, uint256 _query) external;

    /**
     * Used for liveness checks, the bot's response to AgentPing event.
     * Simply emits AgentPingResponse event identifying the owner.
     * NOTE: may only be called by the agent vault owner
     * @param _agentVault the pinged agent vault
     * @param _query repeated `_query` from the agentPing
     * @param _response response data to the query
     */
    //@note The Agent's bot is monitoring the blockchain. It sees the AgentPing event meant for it. This function is called by the bot.
    function agentPingResponse(address _agentVault, uint256 _query, string memory _response) external;
}
