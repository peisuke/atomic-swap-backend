// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract UserInformation {
  mapping (address => string) private addressToName;
  mapping (string => address) private nameToAddress;

  event SetName(address indexed _addr, string _str);
  event RemoveName(address indexed _addr);
  
  function compare(string memory a, string memory b) pure internal returns (bool) {
    if(bytes(a).length != bytes(b).length) {
      return false;
    } else {
      return keccak256(abi.encode(a)) == keccak256(abi.encode(b));
    }
  }

  function getName(address _id) external view returns (string memory) {
    return (addressToName[_id]);
  }

  function getAddress(string memory _name) external view returns (address) {
    return (nameToAddress[_name]);
  }

  function setName(string memory _name) external returns (bool ok) {
    require(nameToAddress[_name] == address(0));
    
    nameToAddress[addressToName[msg.sender]] = address(0);
    addressToName[msg.sender] = _name;
    nameToAddress[_name] = msg.sender;

    emit SetName(msg.sender, _name);
    
    return true;
  }
  
  function removeName() external returns (bool ok) {
    nameToAddress[addressToName[msg.sender]] = address(0);
    addressToName[msg.sender] = "";

    emit RemoveName(msg.sender);
    
    return true;
  }
}
