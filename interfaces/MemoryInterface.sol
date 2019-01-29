pragma solidity ^0.4.24;

interface MemoryInterface {
	
	// Get set function for memory
	
	function getString(bytes32 _key) external view returns(string);
	function setString(bytes32 _key, string _value) external;

	function getUnsignInteger(bytes32 _key) external returns(uint);
	function setUnsignInteger(bytes32 _key, uint _value) external;

	function getAddress(bytes32 _key) external returns(address);
	function setAddress(bytes32 _key, address _value) external;

	function getInteger(bytes32 _key) external returns(int);
	function setInteger(bytes32 _key, int _value) external;

	function getBytes(bytes32 _key) external returns(bytes);
	function setBytes(bytes32 _key, bytes _value) external;

	function getBytes32(bytes32 _key) external returns(bytes32);
	function setBytes32(bytes32 _key, bytes32 _value) external;

	function getBoolean(bytes32 _key) external returns(bool);
	function setBoolean(bytes32 _key, bool _value) external;

	function transfer(address _to, uint _value) external;
	function transferFrom(address _from, uint _value) external;

	// Set permission for address
	
	function allow(address _requester, string _type) external;
	function decline(address _requester, string _type) external;

	// Event logged from Memory

	event AllowedAccess(address _requester, string _type);
	event DeclinedAccess(address _requester, string _type);
}
