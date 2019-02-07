pragma solidity ^0.4.24;

import "../IPMemory.sol";

contract MemoryTest {
	IPMemory mem;
	bool result;

	function MemoryTest(address _mem) public {
		mem = IPMemory(_mem);
	}

	function testUint() external returns(bool){
		string k = "test uint Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeUint(_key,2310);
		return 2310 == mem.getUint(_key);
	}

	function testString() external returns(bool){
		string k = "test string Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeString(_key,"String tested");
		return keccak256(abi.encodePacked("String tested")) == keccak256(abi.encodePacked(mem.getString(_key)));
	}

	function testBool() external returns(bool){
		string k = "test bool Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeBool(_key,true);
		return mem.getBool(_key);
	}

	function testBytes32() external returns(bool) {
		string k = "test bytes32 Memory";
		string tmp = "expected result";
		bytes32 _key = keccak256(abi.encodePacked(k));
		bytes32 _val = keccak256(abi.encodePacked(tmp));
		mem.storeBytes32(_key,_val);
		return _val == mem.getBytes32(_key);
	}

	function testAddress() external returns(bool){
		string k = "test address Memory";
		bytes32 _key = keccak256(abi.encodePacked(k));
		mem.storeAddress(_key,address(0));
		return address(0) == mem.getAddress(_key);
	}

	function run() external view returns(bool) {
		result = this.testAddress() && this.testBytes32() && this.testBool() && this.testString() && this.testUint();
		return result;
	}
}