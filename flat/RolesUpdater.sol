// Dependency file: openzeppelin-solidity/contracts/ownership/Ownable.sol

// pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

// pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


// Dependency file: contracts/user/interfaces/IUserRoles.sol

// pragma solidity ^0.4.24;

contract IUserRoles {
    function addAddressToTester(address _operator) public;

    function addAddressesToTester(address[] _operators) public;

    function isTester(address _operator) public view returns (bool);

    function isDeveloper(address _operator) public view returns (bool);

    function isTesterOrDeveloper(address _operator) public view returns (bool);

    function addAddressToDeveloper(address _operator) public;

    function addAddressesToDeveloper(address[] _operators) public;
}

// Root file: contracts/user/RolesUpdater.sol

pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
// import "contracts/user/interfaces/IUserRoles.sol";

contract RolesUpdater is Ownable {
    address public supervisor;

    IUserRoles public userRoles;

    uint256 public networkId;

    mapping(address => uint256) public userToNonce;

    event UpdateTesterRole(address indexed _user, uint indexed _nonce, bytes32 _testerCodeHash);

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    constructor(IUserRoles _userRoles, uint _networkId, address _supervisor) public {
        userRoles = _userRoles;
        networkId = _networkId;
        supervisor = _supervisor;
    }

    // _hashmessage = hash("${_address}${_nonce}${sha3(_testercode)}${_networkId}")
    // _v, _r, _s are from supervisor's signature on _hashmessage
    function updateTesterRole(uint256 _nonce, bytes32 _testerCodeHash, bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) public {
        address _user = msg.sender;

        // verify the _nonce is right
        require(userToNonce[_user] == _nonce);

        // verify the _hashmessage is signed by supervisor
        require(supervisor == verify(_hashmessage, _v, _r, _s));

        // verify that the _user, _nonce, _value are exactly what they should be
        require(keccak256(abi.encodePacked(_user, _nonce, _testerCodeHash, networkId)) == _hashmessage);

        userRoles.addAddressToTester(_user);

        // after the claiming operation succeeds
        userToNonce[_user] += 1;

        emit UpdateTesterRole(_user, _nonce, _testerCodeHash);
    }

    function verify(bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19EvolutionLand Signed Message For Role Updater:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hashmessage));
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }

    function changeSupervisor(address _newSupervisor) public onlyOwner {
        supervisor = _newSupervisor;
    }

    function changeUserRoles(address _newUserRoles) public onlyOwner {
        userRoles = IUserRoles(_newUserRoles);
    }
}