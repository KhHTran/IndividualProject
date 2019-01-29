pragma solidity ^0.4.24;

import "../interfaces/MemoryInterface.sol";

contract MemberMemory {

	function getMemberEntityID(address _member, string _type, MemoryInterface _memory) external view returns(uint _id) {
		byte32 hash = keccak256(abi.encodePacked(_member,_type,"EntityID"));
		_id = _memory.getUnsignInteger(hash);
	}

	function setMemberEntityID(address _member, string _type, uint _entityID, MemoryInterface _memory) external {
		byte32 hash = keccak256(abi.encodePacked(_member,_type,"EntityID"));
		_memory.setUnsignInteger(hash,_entityID);
	}
}