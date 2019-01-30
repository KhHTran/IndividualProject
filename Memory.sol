pragma solidity ^0.4.24;

import "./Owned.sol";
import "./interfaces/MemoryInterface.sol";
import "./Token.sol";

contract Memory is Owned, MemoryInterface { 
	modifier isAllowed(string _type) {
		require(msg.sender == owner || allowedAccess[encrypt(msg.sender,_type)], "Action not allowed");
		_;
	}

	// Overide get set functions

	mapping(bytes32 => bool) allowedAccess;
	mapping(bytes32 => bytes32) bytes32Map;
	mapping(bytes32 => int) intMap;
	mapping(bytes32 => utin) uintMap;
	mapping(bytes32 => bytes) bytesMap;
	mapping(bytes32 => string) stringMap;
	mapping(bytes32 => bool) boolMap;
	mapping(bytes32 => address) addressMap;
	
	function getString(bytes32 _key) external view returns(string _value) {
		_value = stringMap[_key];
	}
	function setString(bytes32 _key, string _value) external isAllowed("write") {
		stringMap[_key] = _value;
	}

	function getUnsignInteger(bytes32 _key) external view returns(uint _value) {
		_value = uintMap[_key];
	}
	function setUnsignInteger(bytes32 _key, string _value) external isAllowed("write") {
		uintMap[_key] = _value;
	}

	function getAddress(bytes32 _key) external view returns(address _value) {
		_value = addressMap[_key];
	}
	function setAddress(bytes32 _key, address _value) external isAllowed("write") {
		addressMap[_key] = _value;
	}
	
	function getInteger(bytes32 _key) external returns(int _value) {
		_value = intMap[_key]
	}
	function setInteger(bytes32 _key, int _value) external isAllowed("write") {
		intMap[_key] = _value;
	}

	function getBytes(bytes32 _key) external returns(bytes _value) {
		_value = bytesMap[_key];
	}
	function setBytes(bytes32 _key, bytes _value) external isAllowed("write") {
		bytesMap[_key] = _value;
	}

	function getBytes32(bytes32 _key) external returns(bytes32 _value) {
		_value = bytes32Map[_key];
	}
	function setBytes32(bytes32 _key, bytes32 _value) external isAllowed("write") {
		bytes32Map[_key] = _value;
	}

	function getBoolean(bytes32 _key) external returns(bool _value) {
		_value = boolMap[_key];
	}
	function setBoolean(bytes32 _key, bool _value) external isAllowed("write") {
		boolMap[_key] = _value;
	}

	function transfer(address _to, uint _value) external isAllowed("transfer token") {
		assert(Token.transfer(_to,_value));
	}

	function transferFrom(address _from, uint _value) external isAllowed("transfer token") {
		assert(Token.transferFrom(_from,this,_value));
	}

	// allow and decline access can only be done by owner

	function allow(address _requester, string _type) external onlyOwner {
		allowedAccess[keccak256(abi.encodePacked(_requester,_type))] = true;
		emit AllowedAccess(_requester,_type);
	}

	function decline(address _requester, string _type) external onlyOwner {
		allowedAccess[encrypt(_requester,_type)] = false;
		emit DeclinedAccess(_requester,_type);
	}

	function encrypt(address _address, string _string) internal returns(bytes32 _hash) {
		_hash = keccak256(abi.encodePacked(_address,_string));
	}

	function credentialCheck(string _type) private view {
		require(msg.sender == owner || allowedAccess[encrypt(msg.sender,_type)],"Terminated: Lack of sufficient credential");
	}
}