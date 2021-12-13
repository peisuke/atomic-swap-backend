// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";

contract AtomicSwapERC20ToERC20 {
  struct Swap {
    uint256 openValue;
    address openTrader;
    address openContractAddress;
    uint256 closeValue;
    address closeTrader;
    address closeContractAddress;
  }

  enum States {
    INVALID,
    OPEN,
    CLOSED,
    EXPIRED
  }

  mapping (bytes32 => Swap) private swaps;
  mapping (bytes32 => States) private swapStates;

  event Open(bytes32 swapID, address indexed openTrader, address indexed closeTrader);
  event Expire(bytes32 swapID, address indexed openTrader, address indexed closeTrader);
  event Close(bytes32 swapID, address indexed openTrader, address indexed closeTrader);
  event Expire(bytes32 _swapID);
  event Close(bytes32 _swapID);

  modifier onlyInvalidSwaps(bytes32 _swapID) {
    require (swapStates[_swapID] == States.INVALID);
    _;
  }

  modifier onlyOpenSwaps(bytes32 _swapID) {
    require (swapStates[_swapID] == States.OPEN);
    _;
  }

  function open(bytes32 _swapID, uint256 _openValue, address _openContractAddress, uint256 _closeValue, address _closeTrader, address _closeContractAddress) public onlyInvalidSwaps(_swapID) {
    // Transfer value from the opening trader to this contract.
    ERC20 openERC20Contract = ERC20(_openContractAddress);
    require(msg.sender != _closeTrader, 'Opener must not be closer.');
    require(_openValue <= openERC20Contract.allowance(msg.sender, address(this)), 'Less allowance.');
    require(openERC20Contract.transferFrom(msg.sender, address(this), _openValue), 'transfer is failed.');

    // Store the details of the swap.
    Swap memory swap = Swap({
      openValue: _openValue,
      openTrader: msg.sender,
      openContractAddress: _openContractAddress,
      closeValue: _closeValue,
      closeTrader: _closeTrader,
      closeContractAddress: _closeContractAddress
    });
    swaps[_swapID] = swap;
    swapStates[_swapID] = States.OPEN;

    //emit Open(_swapID, _closeTrader);
    emit Open(_swapID, msg.sender, _closeTrader);
  }

  function close(bytes32 _swapID) public onlyOpenSwaps(_swapID) {
    // Close the swap.
    Swap memory swap = swaps[_swapID];
    
    //require(msg.sender == swap.openTrader);
    swapStates[_swapID] = States.CLOSED;

    // Transfer the closing funds from the closing trader to the opening trader.
    ERC20 closeERC20Contract = ERC20(swap.closeContractAddress);
    require(swap.closeValue <= closeERC20Contract.allowance(swap.closeTrader, address(this)));
    require(closeERC20Contract.transferFrom(swap.closeTrader, swap.openTrader, swap.closeValue));

    // Transfer the opening funds from this contract to the closing trader.
    ERC20 openERC20Contract = ERC20(swap.openContractAddress);
    require(openERC20Contract.transfer(swap.closeTrader, swap.openValue));

    emit Close(_swapID, swap.openTrader, swap.closeTrader);
  }

  function expire(bytes32 _swapID) public onlyOpenSwaps(_swapID) {
    // Expire the swap.
    Swap memory swap = swaps[_swapID];
    
    require(msg.sender == swap.openTrader);
    swapStates[_swapID] = States.EXPIRED;

    // Transfer opening value from this contract back to the opening trader.
    ERC20 openERC20Contract = ERC20(swap.openContractAddress);
    require(openERC20Contract.transfer(swap.openTrader, swap.openValue));

    emit Expire(_swapID, swap.openTrader, swap.closeTrader);
  }

  function check(bytes32 _swapID) public view returns (uint256 openValue, address openTrader, address openContractAddress, uint256 closeValue, address closeTrader, address closeContractAddress) {
    Swap memory swap = swaps[_swapID];
    return (swap.openValue, swap.openTrader, swap.openContractAddress, swap.closeValue, swap.closeTrader, swap.closeContractAddress);
  }

  function isOpened(bytes32 _swapID) public view returns (bool ret) {
    States st = swapStates[_swapID];
    return (st == States.OPEN);
  }
}
