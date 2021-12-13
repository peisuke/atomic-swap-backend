// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

abstract contract ERC20 {
  uint public totalSupply;

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  function decimals() virtual public view returns (uint);
  function balanceOf(address who) virtual public view returns (uint);
  function allowance(address owner, address spender) virtual public view returns (uint);

  function transfer(address to, uint value) virtual public returns (bool ok);
  function transferFrom(address from, address to, uint value) virtual public returns (bool ok);
  function approve(address spender, uint value) virtual public returns (bool ok);
}
