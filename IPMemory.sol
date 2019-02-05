pragma solidity ^0.4.24;

contract IPMemory {
	address public owner;
	function TicketManagementSystem() public {
		owner = msg.sender;
	}

	modifier memberNotRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(this.getUint(crypt) == 0,"member is already registered");
		_;
	}

	modifier memberRegistered(address _member,string _type) {
		bytes32 crypt = encrypt(_member,_type);
		require(this.getUint(crypt) > 0,"member is not registered");
		_;
	}

	modifier memberIsPrime() {
		bytes32 crypt = encrypt(msg.sender,"Primary");
		require(this.getUint(crypt) > 0 || msg.sender == owner,"not a primary member");
		_;
	}

	function encrypt(address _address, string _string) internal returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string))
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
	function registerMember(address _member, string _type, string _metadata) 
	external 
	memberNotRegistered(_member,_type) {
		require(_type == "Primary" || _type == "Secondary","Member type should be Primary or Secondary");
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		bytes32 crypt = encrypt(_member,_type);
		this.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		this.storeString(crypt,_metadata);
		emit MemberRegistered(_member,_type);
	}
	function getMemberData(address _member, string _type) external
	memberRegistered(_member,_type) returns(string) {
		bytes32 crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		return this.getString(crypt);
	}
	function updataMemberData(address _member, string _type, string _metadata) 
	external 
	memberRegistered(_member,_type) {
		require(bytes(_metadata).length > 0, "Data needed to be provided");
		crypt = keccak256(abi.encodePacked(_member,_type,"Metadata"));
		this.storeString(crypt,_metadata);
	}

	function registerEvent(string _name, string _url, string _data, uint _start, uint _end, uint _ticketPrice, bytes _signature) 
	external memberIsPrime(msg.sender){

	} 
}