// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

abstract contract TokenInterface {
    function transfer(address _to, uint256 _value) virtual public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool);
    function approve(address _spender, uint256 _value) virtual public returns (bool);
    function balanceOf(address _owner) virtual public view returns (uint256);
    function allowance(address _owner, address _spender) virtual public view returns (uint256);

    event Transfer(address _from, address _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TestERC20 is TokenInterface {
    string public name = "Republic Token";
    string public symbol = "REN";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) override public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _value;
        return _transfer(_from, _to, _value);
    }

    // Approve spender from owner's account
    function approve(address _spender, uint256 _value) override public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Return balance
    function balanceOf(address _owner) override public view returns (uint256) {
        return balances[_owner];
    }

    // Return allowance
    function allowance(address _owner, address _spender) override public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    // Transfer amount from one account to another (may require approval)
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0) && balances[_from] >= _value && _value > 0);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
