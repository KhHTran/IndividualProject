pragma solidity ^0.4.24;

import "../MemberManager.sol";
import "../IPMemory.sol";

contract MemberTest {
	MemberManager memMan;
	IPMemory mem;
	address owner = msg.sender;
	bool result;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}
	
	function setContracts(address _memManAddress, address _memoryAddress) external onlyOwner() {
		memMan = MemberManager(_memManAddress);
		mem = IPMemory(_memoryAddress);
	}

	function testRegisterMemberAndGetData() external returns(bool){
		address _member = address(0);
		string _metadata = "Metadata for test member 0x0";
		bytes32 _metaHash = keccak256(abi.encodePacked(_metadata));
		memMan.registerMember(_member,"Primary",_metadata);
		bytes32 _key = keccak256(abi.encodePacked(_member,"Primary"));
		bool x = 1 == mem.getUint(_key);
		_key = keccak256(abi.encodePacked(_member,"Primary","Metadata"));
		bool y = _metaHash == keccak256(abi.encodePacked(mem.getString(_key)));
		x = x && y;
		y = _metaHash == keccak256(abi.encodePacked(memMan.getMemberData(address(0),"Primary")));
		x = x && y;
		return x;
	}

	function testUpdateMember() external returns(bool){
		string _metadata = "New _metadata for test member 0x0";
		bytes32 _metaHash = keccak256(abi.encodePacked(_metadata));
		memMan.updataMemberData(address(0),"Primary",_metadata)
		bool x = _metaHash == memMan.getMemberData(address(0),"Primary");
		return x;
	}

	function runTests() external {
		result = this.testRegisterMemberAndGetData() && this.testUpdateMember();
	}

	function getResult() external view returns(bool) {
		return result;
	}
}