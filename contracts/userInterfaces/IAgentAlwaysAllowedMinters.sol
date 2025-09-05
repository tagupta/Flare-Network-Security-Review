// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

//@note whitelist management system for specific Agents
interface IAgentAlwaysAllowedMinters {
    //@note Agent gives permission to this specific Ethereum address _minter to mint FAssets using agent's vault's collateral anytime they want, without needing my further approval.
    function addAlwaysAllowedMinterForAgent(address _agentVault, address _minter) external;
    //@note revoking the minting privileges for this address _minter. _minter can no longer use _agentVault vault without approval again.
    function removeAlwaysAllowedMinterForAgent(address _agentVault, address _minter) external;
    //@note returns a list of addresses with pre-approved minting permissions for _agentVault vault.
    function alwaysAllowedMintersForAgent(address _agentVault) external view returns (address[] memory);
}
