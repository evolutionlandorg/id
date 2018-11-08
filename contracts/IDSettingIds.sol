pragma solidity ^0.4.24;

import "@evolutionland/common/contracts/SettingIds.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";

contract IDSettingIds is SettingIds {

    bytes32 public constant CONTRACT_DIVIDENDS_POOL = "CONTRACT_DIVIDENDS_POOL";

    bytes32 public constant CONTRACT_CHANNEL_DIVIDEND = "CONTRACT_CHANNEL_DIVIDEND";

    // TODO: recommend to move this property into common-contracts repo.
    // this is a copy from AuctionSettingIds in market-contracts.
    bytes32 public constant CONTRACT_FROZEN_DIVIDEND = "CONTRACT_FROZEN_DIVIDEND";
}