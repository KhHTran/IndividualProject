pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract MemberManagement {
	modifier memberNotRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(IPMemory.getUint(crypt) == 0,"member is already registered");
		_;
	}

	modifier memberRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(IPMemory.getUint(crypt) > 0,"member is not registered");
		_;
	}

	modifier memberIsPrime() {
		bytes32 crypt = encrypt(msg.sender,"Primary");
		require(IPMemory.getUint(crypt) > 0 || msg.sender == owner,"not a primary member");
		_;
	}

	function encrypt(address _address, string _string) internal returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string))
	}

	function registerMember(address _member, string _type, string _metadata) 
	external 
	memberNotRegistered(_member,_type) {
		require(_type == "Primary" || _type == "Secondary","Member type should be Primary or Secondary");
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		bytes32 crypt = encrypt(_member,_type);
		IPMemory.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		IPMemory.storeString(crypt,_metadata);
		emit MemberRegistered(_member,_type);
	}

	function getMemberData(address _member, string _type) external
	memberRegistered(_member,_type) returns(string) {
		bytes32 crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		return IPMemory.getString(crypt);
	}

	function updataMemberData(address _member, string _type, string _metadata) 
	external 
	memberRegistered(_member,_type) {
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		IPMemory.storeString(crypt,_metadata);
	}

	function registerEvent(string _name, string _url, uint _start, uint _end, uint _ticketPrice, bytes _signature) 
	external memberIsPrime(msg.sender){

	}
}