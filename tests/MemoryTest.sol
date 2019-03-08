pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "remix_tests.sol";

contract MemoryTest {
	IPMemory mem;
	bool result;
	address owner = msg.sender;
	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}
	function setMemoryContract(address _mem) external onlyOwner() {
		mem = IPMemory(_mem);
	}

	function testUint() external {
		string memory k = "test uint Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeUint(_key,2310);
		Assert.equal(2310,mem.getUint(_key),"Wrong store key");
	}

	function testString() external returns(bool){
		string memory k = "test string Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeString(_key,"String tested");
		bytes32 b1 = keccak256(abi.encodePacked(mem.getString(_key)));
		bytes32 b2 = keccak256(abi.encodePacked("String tested"));
		Assert.equal(b1,b2,"Wrong store string");
	}

	function testBool() external {
		string memory k = "test bool Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeBool(_key,true);
		Assert.equal(true,mem.getBool(_key),"Wrong store bool");
	}

	function testBytes32() external {
		string memory k = "test bytes32 Memory";
		string memory tmp = "expected result";
		bytes32 _key = keccak256(abi.encodePacked(k));
		bytes32 _val = keccak256(abi.encodePacked(tmp));
		mem.storeBytes32(_key,_val);
		Assert.equal(_val,mem.getBytes32(_key),"Wrong store bytes23");
	}

	function testAddress() external {
		string memory k = "test address Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		address a = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
		mem.storeAddress(_key,a);
		Assert.equal(a,mem.getAddress(_key),"Wrong store address");
	}


	function test() external {
		this.testUint();
		this.testString();
		this.testBool();
		this.testBytes32();
		this.testAddress();
	}
}