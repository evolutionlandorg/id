pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/SettingIds.sol";
import "@evolutionland/common/contracts/DSAuth.sol";

contract ChannelDevidend is DSAuth, SettingIds {
    event TrasnferredDividend(address indexed _dest, uint256 _value);

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    ISettingsRegistry public registry;

    address public dvidendTakeBack;

    constructor(address _registry, address _dvidendTakeBack) public {
        registry = ISettingsRegistry(_registry);
        dvidendTakeBack = _dvidendTakeBack;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);

        if(msg.sender == ring) {
            // trigger settlement
            settlement();
        }
    }

    function settlement() public {
        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);

        uint256 balance = ERC20(ring).balanceOf(address(this));
        if ( balance > 0 ) {
            ERC20(ring).transfer(dvidendTakeBack, balance);

            emit TrasnferredDividend(dvidendTakeBack, balance);
        }
    }
    
    function claimTokens(address _token) public auth {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }

}