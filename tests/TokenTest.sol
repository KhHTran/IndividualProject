pragma solidity ^0.4.24;

import "./Token.sol";
import "remix_tests.sol";

contract TokenTest {
	Token token;
	address owner = msg.sender;
	address testUser = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}
	function setContract(address _token) external onlyOwner() {
		token = Token(_token);
	}
	
	function test0() external {
		Assert.equal(0,token.getBalance(testUser),"Innitial balance test");
		Assert.equal(token.getTotalBooking(testUser),0,"Innitial booking test");
	}

	function test1() external {
		token.deposit(testUser,230);
		Assert.equal(230,token.getBalance(testUser),"Deposit test");
		token.withdraw(testUser,110);
		Assert.equal(120,token.getBalance(testUser),"Withdraw test");
	}

	function test2() external {
		token.transfer(testUser,user,10);
		Assert.equal(token.getBalance(testUser),110,"transfer sender balance test");
		Assert.equal(token.getBalance(user),10,"transfer receiver balance test");
	}

	function test3() external {
		token.bookToken(testUser,20);
		Assert.equal(token.getTotalBooking(testUser),20,"book token test");
		token.freeBooking(testUser,10);
		Assert.equal(token.getTotalBooking(testUser),10,"free booking test");
	}

	function test4() external {
		ThrowProxy throwproxy = new ThrowProxy(address(token)); 
	    Token(address(throwproxy)).bookToken(testUser,120);
	    bool r = throwproxy.execute.gas(200000)(); 
	    Assert.equal(false, r, "Insufficient funds revert test!");
	    Assert.equal(token.getTotalBooking(testUser),10,"Insufficient funds revert test!");
	}
}

// Proxy contract for testing throws
contract ThrowProxy {
	address public target;
	bytes data;

	function ThrowProxy(address _target) {
		target = _target;
	}

	//prime the data using the fallback function.
	function() {
		data = msg.data;
	}

	function execute() returns (bool) {
		return target.call(data);
	}
}