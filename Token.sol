pragma solidity ^0.4.24;

import "./interfaces/EIP20.sol";
import "./Owned.sol";

contract Token is Owned, EIP20 {
	uint private _totalSupply;
	mapping(address => uint) private balances;
	mapping(address => mapping(address => uint)) private allowed;
	function totalSupply() public view returns (uint) {
		return _totalSupply;
	}
	function balanceOf(address _owner) public view returns (uint balance) {
		balance = balances[_owner];
	}
	function transfer(address _to, uint _value) public returns (bool success) {
		require(balances[msg.sender] >= _value);
		require (_to != address(0));

		balances[msg.sender] -= _value;
		balances[_to] += _value;
		emit Transfer(msg.sender,_to,_value);
		return true;
	}
	function transferFrom(address _from, address _to, uint _value) public returns(bool success) {
		require(balances[_from] >= _value);
		require(allowed[msg.sender][_from] >= _value);
		require (_to != address(0));

		balances[_from] -= _value;
		balances[_to] += _value;
		allowed[msg.sender][_from] -= _value; 
		emit Transfer(_from,_to,_value);
		return true;
	}
	function approve(address _spender, uint _value) public returns (bool success) {
		require (_spender != address(0));

		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender,_spender,_value);
		return true;
	}
	function allowance(address _owner, address _spender) public view returns (uint remaining) {
		return allowed[_owner][_spender];
	}
	function mint(address _account, uint _amount) internal {
		require(_account != address(0));

		_totalSupply += _amount;
		balances[_account] += _amount;
		emit Transfer(address(0),_account,_amount);
	}
	function burn(address _account, uint _amount) internal {
		require(_account != address(0));
		require(_amount <= balances[_account]);

		_totalSupply -= _amount;
		balances[_account] -= _amount;
		emit Transfer(_account,address(0),_amount);
	}
}