pragma solidity ^0.4.24;

import "../interfaces/MemoryInterface.sol";

contract TokenMemory {
	function getRequiredDeposit(address _member, MemoryInterface _memory) external view returns(uint) {
		bytes32 key = keccak256(abi.encodePacked(_member,"Required Deposit"));
		return _memory.getUnsignInteger(key);
	}

	function setRequiredDeposit(address _member, uint _amount, MemoryInterface _memory) external {
		bytes32 key = keccak256(abi.encodePacked(_member,"Required Deposit"));
		_memory.setUnsignInteger(key,_amount);
	}

	function getDepositBalance(address _member, MemoryInterface _memory) external view returns(uint) {
		bytes32 key = keccak256(abi.encodePacked(_member,"Deposit Balance"));
		return _memory.getUnsignInteger(key);
	}
}