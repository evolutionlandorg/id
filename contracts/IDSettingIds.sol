pragma solidity ^0.4.24;

import "@evolutionland/common/contracts/SettingIds.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";

contract IDSettingIds is SettingIds {

    bytes32 public constant CONTRACT_CHANNEL_DIVIDEND = "CONTRACT_CHANNEL_DIVIDEND";

    bytes32 public constant CONTRACT_FROZEN_DIVIDEND = "CONTRACT_FROZEN_DIVIDEND";
}