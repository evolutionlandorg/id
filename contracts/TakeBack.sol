pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Claim is Ownable{

    using StringHelper for *;


    // address of RING.sol on ethereum
    address public ring;

    mapping (address => uint) public userToNonce;


    // used for old&new users to claim their ring out
    event TakeBack(address indexed _user, uint indexed _nonce);
    // used for owner to claim all kind of token
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);


    // _hashmessage = hash("${_user}${_nonce}${_value}")
    // _v, _r, _s are from owner's signature on _hashmessage
    // claimRing(...) is invoked by the user who want to claim rings
    // while the _hashmessage is signed by owner
    function takeBack(uint _nonce, uint _value, bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) public {

        address _user = msg.sender;

        // verify the _nonce is right
        require(userToNonce[_user] == _nonce);

        // verify the _hashmessage is signed by owner
        require(owner == verify(_hashmessage, _v, _r, _s));

        // verify that the _user, _nonce, _value are exactly what they should be
        require(keccak256(_user,_nonce,_value) == _hashmessage);

        // transfer ring from address(this) to _user
        ERC20 ringtoken = ERC20(ring);
        ringtoken.transfer(_user, _value);

        // after the claiming operation succeeds
        userToNonce[_user]  += 1;
        emit TakeBack(_user, _nonce);
    }


    function verify(bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19EvolutionLand Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, _hashmessage);
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
    }

    function claimTokens(address _token) onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }


    function setRING(address _token) onlyOwner public {
        ring = _token;
    }
}