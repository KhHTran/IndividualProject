pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract Token {
	address owner = msg.sender;
	IPMemory mem;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}

	modifier sufficientBalance(uint _amount) {
		require(this.getBalance() > this.getTotalBooking(msg.sender) + _amount, "Insufficient funds");
		_;
	}

	function setMemoryContract(address _mem) external onlyOwner() {
		mem = IPMemory(_mem);
	}

	function getBalance(address _user) external returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Balance of User"));
		return mem.getUint(_key);
	}

	function transfer(address _receiver, uint _amount) external sufficientBalance(_amount) {
		require(_amount > 0, "transfer amount is negative");
		uint balance = this.getBalance(msg.sender);
		bytes32 _key = keccak256(abi.encodePacked(msg.sender,"Token Balance of User"));
		mem.storeUint(_key,balance - _key);
		balance = this.getBalance(_receiver);
		bytes32 _key = keccak256(abi.encodePacked(_receiver,"Token Balance of User"));
		mem.storeUint(_key,balance + _key);
	}

	function deposit(uint _amount) external {
		require(_amount > 0, "deposit amount is negative");
		uint balance = this.getBalance();
		bytes32 _key = keccak256(abi.encodePacked(msg.sender,"Token Balance of User"));
		mem.storeUint(_key,balance + _key);	
	}

	function withdraw(uint _amount) external sufficientBalance(_amount) {
		require(_amount > 0, "withdraw amount is negative");
		uint balance = this.getBalance();
		bytes32 _key = keccak256(abi.encodePacked(msg.sender,"Token Balance of User"));
		mem.storeUint(_key,balance - _key);	
	}

	function bookToken(uint _amount) external sufficientBalance(_amount){
		require(_amount > 0, "booking amount is negative");
		uint booking = this.getTotalBooking(msg.sender);
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Booking Amount of User"));
		mem.storeUint(_key, booking + _amount);
	}

	function freeBooking(address _user, uint _amount) external {
		require(_amount > 0, "Free amount is negative");
		uint total = this.getTotalBooking(_user);
		require(total > _amount, "booked amount < free amount");
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Booking Amount of User"));
		mem.storeUint(_key, total - _amount); 
	}

	function getTotalBooking(address _user) external returns(uint){
		bytes32 _key = keccak256(abi.encodePacked(_user,"Token Booking Amount of User"));
		return mem.getUint(_key);
	}
}