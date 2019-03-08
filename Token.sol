pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract Token {
	address owner = msg.sender;
	IPMemory mem;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}

	modifier sufficientBalance(address _member, uint _amount) {
		require(this.getBalance(_member) > this.getTotalBooking(_member) + _amount, "Insufficient funds");
		_;
	}

	function setMemoryContract(address _mem) external onlyOwner() {
		mem = IPMemory(_mem);
	}

	function getBalance(address _user) external view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Balance of User"));
		return mem.getUint(_key);
	}

	function transfer(address _sender, address _receiver, uint _amount) external sufficientBalance(_sender,_amount) {
		require(_amount > 0, "transfer amount is negative");
		uint balance = this.getBalance(_sender);
		bytes32 _key = keccak256(abi.encodePacked(_sender,"Token Balance of User"));
		mem.storeUint(_key,balance - _amount);
		balance = this.getBalance(_receiver);
		_key = keccak256(abi.encodePacked(_receiver,"Token Balance of User"));
		mem.storeUint(_key,balance + _amount);
	}

	function deposit(address _member, uint _amount) external {
		require(_amount > 0, "deposit amount is negative");
		uint balance = this.getBalance(_member);
		bytes32 _key = keccak256(abi.encodePacked(_member,"Token Balance of User"));
		mem.storeUint(_key,balance + _amount);	
	}

	function withdraw(address _member, uint _amount) external sufficientBalance(_member,_amount) {
		require(_amount > 0, "withdraw amount is negative");
		uint balance = this.getBalance(_member);
		bytes32 _key = keccak256(abi.encodePacked(_member,"Token Balance of User"));
		mem.storeUint(_key,balance - _amount);	
	}

	function bookToken(address _member,uint _amount) external sufficientBalance(_member,_amount){
		require(_amount > 0, "booking amount is negative");
		uint booking = this.getTotalBooking(_member);
		bytes32 _key = keccak256(abi.encodePacked(_member,"Token Booking Amount of User"));
		mem.storeUint(_key, booking + _amount);
	}

	function freeBooking(address _user, uint _amount) external {
		require(_amount > 0, "Free amount is negative");
		uint total = this.getTotalBooking(_user);
		require(total > _amount, "booked amount < free amount");
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Booking Amount of User"));
		mem.storeUint(_key, total - _amount); 
	}

	function getTotalBooking(address _user) external view returns(uint){
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Booking Amount of User"));
		return mem.getUint(_key);
	}
}