pragma solidity ^0.4.24;

interface MemberInterface {

	function registerMember(address _member, string _type, string _proof, string _url, string _data) external;
	function deregisterMember(address _member, string _type) external;

	function registerDeposit(string _type) external returns(uint);
	function getMemberDeposit(address _member, string _type) external returns(uint);

	event memberRegistered(address _member, string _type, string _proof, string _data, string _url, uint _deposit);
	event memberDeregistered(address _member, string _type);
}