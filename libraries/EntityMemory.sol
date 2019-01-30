pragma solidity ^0.4.24;

import "../interfaces/MemoryInterface.sol";

contract EntityMemory {

	function getCount(MemoryInterface _memory) external view returns(uint _count) {
		byte32 key = keccak256(abi.encodePacked("Entity Count"));
		_count = _memory.getUnsignInteger(key);
	}

	function setCount(uint _count, MemoryInterface _memory) external {
		byte32 key = keccak256(abi.encodePacked("Entity Count"));
		_memory.setUnsignInteger(key,_count);	
	}

	function registerDeposit(uint _entityID, uint _deposit, MemoryInterface _memory) external {
		byte32 key = keccak256(abi.encodePacked("EntityID",_entityID,"Deposit"));
		_memory.setUnsignInteger(key,deposit);
	}

	function getDeposit(uint _entityID, MemoryInterface _memory) external view returns(uint _deposit) {
		byte32 key = keccak256(abi.encodePacked("EntityID",_entityID,"Deposit"));
		_deposit = _memory.getUnsignInteger(key);
	}

	function setDeposit((uint _entityID, uint _deposit, MemoryInterface _memory) external {
		this.registerDepositor(_entityID,_deposit,_memory)
	}

	function registerDepositor(uint _entityID, address _depositor, MemoryInterface _memory) external {
		byte32 key = keccak256(abi.encodePacked("EntityID",_entityID,"Depositor"));
		_memory.setAddress(key,_depositor);
	}

	function getDepositor(uint _entityID, MemoryInterface _memory) external view returns(address _depositor) {
		byte32 key = keccak256(abi.encodePacked("EntityID",_entityID,"Depositor"));
		_depositor = _memory.getAddress(key);
	}
}