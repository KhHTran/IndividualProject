pragma solidity ^0.4.24;

import "../interfaces/MemoryInterface.sol";
import "../interfaces/MemberInterface.sol";
import "./MemberMemory.sol";
import "./Entity.sol";

contract MemberLib {
	byte32 const primeType = keccak256(abi.encodePacked("Prime"));
	byte32 const secondType = keccak256(abi.encodePacked("Second"));

	modifier correctType(string _type) {
		byte32 typeEncoded = keccak256(abi.encodePacked(_type));
		bool compare = typeEncoded == primeType || typeEncoded == secondType;
		require(compare, "Member type not correct");
		_;
	}

	modifier isRegistered(address _member, string _type, MemoryInterface _memory) {
		require(MemberMemory.getMemberEntityID(_member,_type,_memory) > 0, "Member-type pair is not registered");
		_;
	}

	modifier isNotRegistered(address _member, string _type, MemoryInterface _memory) {
		require(MemberMemory.getMemberEntityID(_member,_type,_memory) == 0, "Member-type pair is registered");
		_;
	}

	function registerDeposit(string _type) public view correctType(_type) returns(uint _amount) {
		// will define later on
		_amount = 100;
	}

	function registerMember(address _member, string _type, string _proof, string _data, string _url, MemoryInterface _memory) public 
	correctType(_type)
	isNotRegistered(_member,_type,_memory) {
		require(bytes (_proof).length > 0, "Proof length must be more than 0");
		require(bytes (_url).length > 0, "URL length must be more than 0");
		require(bytes (_data).length > 0, "Data length must be more than 0");
		
		uint deposit = registerDeposit(_type);
		uint enityID = Entity.newEntity(_member,deposit,_memory);
		MemberMemory.setMemberEnityID(_member,_type,enityID,_memory);
		emit memberRegistered(_member, _type, _proof, _data, _url, deposit);
	}

	function deresigterMember(address _member, string _type, MemoryInterface _memory) external
	correctType(_type) 
	isRegistered(_member,_type,_memory){
		uint enityID = MemberMemory.getMemberEntityID(_member,_type,_memory);
		Entity.removeEntity(enityID,_memory);
		MemberMemory.setMemberEnityID(_member,_type,0,_memory);
		emit memberDeregistered(_member, _type);
	}
}