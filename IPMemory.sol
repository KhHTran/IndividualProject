pragma solidity ^0.4.24;

contract IPMemory {
	address public owner;
	function TicketManagementSystem() public {
		owner = msg.sender;
	}

	mapping(bytes32 => address) private addressMap;
	mapping(bytes32 => uint) private uintMap;
	mapping(bytes32 => bytes32) private bytes32Map;
	mapping(bytes32 => string) private stringMap;
	mapping(bytes32 => bool) private boolMap;

	function getString(bytes32 _key) external view returns(string) {
		return stringMap[_key];
	}
	function getUint(bytes32 _key) external view returns(uint) {
		return uintMap[_key];
	}
	function getBytes32(bytes32 _key) external view returns(bytes32) {
		return bytes32Map[_key];
	}
	function getAddress(bytes32 _key) external view returns(address) {
		return addressMap[_key];
	}
	function getBoolean(bytes32 _key) external view returns(bool) {
		return boolMap[_key];
	}
	function storeString(bytes32 _key, string _value) external {
		stringMap[_key] = _value;
	}
	function storeBytes32(bytes32 _key, bytes32 _value) external {
		bytes32Map[_key] = _value;
	}
	function storeUint(bytes32 _key, uint _value) external {
		uintMap[_key] = _value;
	}
	function storeAddress(bytes32 _key, address _value) external {
		addressMap[_key] = _value;
	}
	function storeBool(bytes32 _key, bool _value) external {
		boolMap[_key] = _value;
	}
}