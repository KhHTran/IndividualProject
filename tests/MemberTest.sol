pragma solidity ^0.4.24;

import "./MemberManager.sol";
import "./IPMemory.sol";
import "remix_tests.sol";

contract PrimaryMemberTest {
	MemberManager memMan;
	IPMemory mem;
	address owner = msg.sender;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}
	
	function setContracts(address _memManAddress, address _memoryAddress) external onlyOwner() {
		memMan = MemberManager(_memManAddress);
		mem = IPMemory(_memoryAddress);
	}

	function testRegisterMemberAndGetData() external {
		string memory _metadata = "Metadata for test member";
		bytes32 _metaHash = keccak256(abi.encodePacked(_metadata));
	    memMan.registerMember(msg.sender,"Primary",_metadata);
		string memory s = "Primary";
		bytes32 _key = keccak256(abi.encodePacked(msg.sender,s));
		Assert.equal(mem.getUint(_key),1,"User-type not marked in memory");
		bytes32 result = keccak256(abi.encodePacked(memMan.getMemberData(msg.sender,"Primary")));
		Assert.equal(_metaHash,result,"Get Member Data is incorrect");
	}

	function testUpdateMember() external {
		string memory _metadata = "New _metadata for test member";
		bytes32 _metaHash = keccak256(abi.encodePacked(_metadata));
		memMan.updataMemberData(msg.sender,"Primary",_metadata);
		bytes32 result = keccak256(abi.encodePacked(memMan.getMemberData(msg.sender,"Primary")));
		Assert.equal(_metaHash,result,"Get Member Data is incorrect");
	}
}