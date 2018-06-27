pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

import './RING.sol';
import './StringHelper.sol';
import './erc20/erc20.sol';

contract Claim {

    using StringHelper for *;

    // this contract's superuser
    address public supervisor;

    // address of RING.sol on ethereum
    address public ring;

    mapping (address => uint) public userToNonce;


    constructor(address _supervisor) public {
        supervisor  = _supervisor;
    }

    modifier onlySupervisor() {
        require(supervisor == msg.sender);
        _;
    }

    // used for old&new users to claim their ring out
    event ClaimedRING(address indexed _user, uint indexed _nonce);
    // used for supervisor to claim all kind of token
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);


    // _hashmessage = hash("${_user}${_nonce}${_value}")
    // _v, _r, _s are from supervisor's signature on _hashmessage
    // claimRing(...) is invoked by the user who want to claim rings
    // while the _hashmessage is signed by supervisor
    function claimRing(uint _nonce, uint _value, bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) public {

        address _user = msg.sender;

        // verify the _nonce is right
        require(userToNonce[_user] + 1 == _nonce);

        // verify the _hashmessage is signed by supervisor
        require(supervisor == verify(_hashmessage, _v, _r, _s));


        string userStr = _user.addrToString();
        string nonceStr = _nonce.uint2str();
        string valueStr = _value.uint2str();

        // verify that the _user, _nonce, _value are exactly what they should be
        require(keccak256(userStr,nonceStr,valueStr) == _hashmessage);

        // transfer ring from address(this) to _user
        ERC20 ringtoken = ERC20(ring);
        ringtoken.transfer(_user, _value);

        // after the claiming operation succeeds
        userToNonce[_user]  += 1;
        emit ClaimedRING(_user, _nonce);
    }


    function verify(bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19EvolutionLand Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, _hashmessage);
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
    }

    function claimTokens(address _token) onlySupervisor {
        if (_token == 0x0) {
            supervisor.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(supervisor, balance);

        emit ClaimedTokens(_token, controller, balance);
    }

    function setSupervisor(address _supervisor) onlySupervisor public {
        supervisor = _supervisor;
    }

    function setRING(address _token) onlySupervisor public {
        ring = _token;
    }
}