var ERC202ERC20 = artifacts.require("./AtomicSwapERC20ToERC20.sol");
//var ERC20 = artifacts.require("./ERC20.sol");
var TestERC20 = artifacts.require("./TestERC20.sol");
var Test2ERC20 = artifacts.require("./Test2ERC20.sol");
var UserInformation = artifacts.require("./UserInformation.sol");

module.exports = function(deployer) {
  deployer.deploy(ERC202ERC20);
  //deployer.deploy(ERC20);
  deployer.deploy(TestERC20);
  deployer.deploy(Test2ERC20);
  deployer.deploy(UserInformation);
};
