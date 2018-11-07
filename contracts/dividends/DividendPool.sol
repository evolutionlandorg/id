pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@evolutionland/common/contracts/interfaces/ERC223.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/SettingIds.sol";
import "@evolutionland/common/contracts/DSAuth.sol";

contract DevidendPool is DSAuth, SettingIds {
    using SafeMath for *;

    event TransferredFrozenDividend(address indexed _dest, uint256 _value);
    event TransferredChannelDividend(address indexed _dest, uint256 _value);

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    ISettingsRegistry public registry;

    address public channelDividend;
    address public frozenDividend;

    constructor(address _registry, address _channelDividend, address _frozenDividend) public {
        registry = ISettingsRegistry(_registry);
        channelDividend = _channelDividend;
        frozenDividend = _frozenDividend;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);
        address kton = registry.addressOf(SettingIds.CONTRACT_KTON_ERC20_TOKEN);

        if (msg.sender == ring) {
            // trigger settlement
            settlement();
        }

        if (msg.sender == kton) {
            // TODO: burn these kton.
        }
    }

    function settlement() public {
        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);
        address kton = registry.addressOf(SettingIds.CONTRACT_KTON_ERC20_TOKEN);

        uint256 balance = ERC20(ring).balanceOf(address(this));
        if ( balance > 0 ) {
            uint256 ktonSupply = ERC20(kton).totalSupply();

            uint256 frozenKton = ERC20(ring).balanceOf(frozenDividend);

            uint256 frozenBalance = frozenKton.mul(balance).div(ktonSupply);

            ERC223(ring).transfer(frozenDividend, frozenBalance, "0x0");

            emit TrasnferredFrozenDividend(frozenDividend, balance);

            ERC20(ring).transfer(channelDividend, balance.sub(frozenBalance));
            
            emit TrasnferredChannelDividend(channelDividend, balance.sub(frozenBalance));
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