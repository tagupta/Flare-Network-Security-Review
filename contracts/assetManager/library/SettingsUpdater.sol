// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Globals} from "./Globals.sol";
import {AssetManagerSettings} from "../../userInterfaces/data/AssetManagerSettings.sol";

library SettingsUpdater {
    error TooCloseToPreviousUpdate();

    struct UpdaterState {
        mapping(bytes32 => uint256) lastUpdate;
    }

    bytes32 internal constant UPDATES_STATE_POSITION = keccak256("fasset.AssetManager.UpdaterState");

    //@audit-low same message.signature - selector of two different funtions can cause collision:
    //@note Time lock mechanism uses msg.sig which allows functions with identical selectors to bypass time lock by sharing the same lock state.
    function checkEnoughTimeSinceLastUpdate() internal {
        //@note bytes32 actionId = keccak256(abi.encode(address(this), msg.sig));
        checkEnoughTimeSinceLastUpdate(msg.sig);
    }

    function checkEnoughTimeSinceLastUpdate(bytes32 _action) internal {
        UpdaterState storage _state = _getUpdaterState();
        AssetManagerSettings.Data storage settings = Globals.getSettings();
        uint256 lastUpdate = _state.lastUpdate[_action];
        require(
            lastUpdate == 0 || block.timestamp >= lastUpdate + settings.minUpdateRepeatTimeSeconds,
            TooCloseToPreviousUpdate()
        );
        _state.lastUpdate[_action] = block.timestamp;
    }

    function _getUpdaterState() private pure returns (UpdaterState storage _state) {
        // Only direct constants are allowed in inline assembly, so we assign it here
        bytes32 position = UPDATES_STATE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            _state.slot := position
        }
    }
}
