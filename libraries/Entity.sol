pragma solidity ^0.4.24;

import "./interfaces/EntityMemory.sol";
import "../interfaces/MemoryInterface.sol";

contract Entity {
	function newEntity(address _member, uint _deposit, MemoryInterface _memory) external view returns(uint _enityID) {
		_entityID = EntityMemory.getCount(_memory) + 1;
		EntityMemory.setCount(_entityID,_memory);
		EntityMemory.registerDeposit(_entityID,_deposit,_memory);
		EntityMemory.registerDepositor(_entityID,_member,_memory);
	}

	function removeEntity(uint _enityID, MemoryInterface _memory) external {
		this.freeDeposit(_entityID,_memory);
	}

	function freeDeposit(uint _entityID, MemoryInterface _memory) external {
		uint deposit = EntityMemory.getDeposit(_entityID,_memory);
		address depositor = EntityMemory.getDepositor(_entityID,_memory);
		EntityMemory.setDeposit(_entityID,0,_memory);
		/*
		ToDo: recalculate the deposit balance
		*/
	}
}