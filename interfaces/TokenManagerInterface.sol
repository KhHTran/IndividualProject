pragma solidity ^0.4.24;

interface TokenManagerInterface {
	event WithdrawToken(address _address, uint _amount, string _type);
	event DepositToken(address _address, uint _amount, string _type);

	function withdrawToken(uint _amount, string _type) external;
	function depositToken(uint _amount, string _type) external;
	function transferToken(uint _amount, string _type) external;
	function getBalances(uint _amount, string _type) external view return(uint);
}