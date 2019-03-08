pragma solidity ^0.4.24;

import "./Token.sol";
import "remix_tests.sol";

contract TokenTest {
	IPMemory mem;
	Token token;
	address owner = msg.sender;
	address testUser = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}
	function setContract(address _token, address _mem) external onlyOwner() {
		mem = IPMemory(_mem);
		token = Token(_token);
	}

	function testTokenContract() external {
		address user = 0x583031d1113ad414f02576bd6afabfb302140225;
		Assert.equal(0,token.getBalance(testUser),"Innitial balance not 0");
		token.deposit(testUser,230);
		Assert.equal(230,token.getBalance(testUser),"Deposit not working");
		token.withdraw(testUser,110);
		Assert.equal(120,token.getBalance(testUser),"Withdraw not working");
		Assert.equal(token.getTotalBooking(testUser),0,"Innitial booking not 0");
		token.transfer(testUser,user,10);
		Assert.equal(token.getBalance(testUser),110,"transfer sender balance not working");
		Assert.equal(token.getBalance(user),10,"transfer receiver balance not working");
		token.bookToken(testUser,20);
		Assert.equal(token.getTotalBooking(testUser),20,"book token not working");
		token.freeBooking(testUser,10);
		Assert.equal(token.getTotalBooking(testUser),10,"free booking not working");
	}
}