pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract MemberManager {
	IPMemory mem;
	address owner = msg.sender;
	bytes32 constant primaryHash = keccak256(abi.encodePacked("Primary"));
	bytes32 constant secondaryHash = keccak256(abi.encodePacked("Secondary"));
	event MemberRegistered(address _member, string _type);

	modifier onlyOwner() {
		require(msg.sender == owner,"Can only performed by owner");
		_;
	}

	modifier memberNotRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(mem.getUint(crypt) == 0,"member is already registered");
		_;
	}

	modifier memberRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(mem.getUint(crypt) > 0,"member is not registered");
		_;
	}

	function setMemoryContract(address _mem) external onlyOwner() {
		mem = IPMemory(_mem);
	}

	function encrypt(address _address, string _string) internal returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string));
	}

	function registerMember(string _type, string _metadata) 
	external 
	memberNotRegistered(msg.sender,_type) {
	    bytes32 hash = keccak256(abi.encodePacked(_type));
		require(hash == primaryHash || hash == secondaryHash,"Member type should be Primary or Secondary");
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		bytes32 crypt = encrypt(msg.sender,_type);
		mem.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(msg.sender,_type,"Metadata"));
		mem.storeString(crypt,_metadata);
		emit MemberRegistered(msg.sender,_type);
	}

	function getMemberData(address _member, string _type) external
	memberRegistered(_member,_type) returns(string) {
		bytes32 crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		return mem.getString(crypt);
	}

	function updataMemberData(string _type, string _metadata) 
	external 
	memberRegistered(msg.sender,_type) {
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		bytes32 crypt = keccak256(abi.encodePacked(msg.sender,_type,"Metadata"));
		mem.storeString(crypt,_metadata);
	}
}