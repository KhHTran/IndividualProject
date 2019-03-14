pragma solidity ^0.4.24;

import "./TicketManager.sol";
import "./IPMemory.sol";
import "./EventManager.sol";
import "remix_tests.sol";

contract TicketTest {
	IPMemory mem;
	EventManager eventMan;
	address owner = msg.sender;
	address userP = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	address userS = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
	address userS2 = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
	uint eventID = 0;
	TicketManager ticketMan;

	modifier onlyOwner() {
		require (msg.sender == owner, "Not authorised");
		_;
	}

	function setUp(address m, address tick, address eve) external {
		mem = IPMemory(m);
		ticketMan = TicketManager(tick);
		bytes32 crypt = keccak256(abi.encodePacked(userP,"Primary"));
		mem.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(userS,"Secondary"));
		mem.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(userS2,"Secondary"));
		mem.storeUint(crypt,1);
		eventMan = EventManager(eve);
		eventMan.registerEvent(userS,"TicketTestEvent","example.com",now + 400, now + 100000, 10);
	}

	function testBuyTicket() external {
	    string memory meta = "Ticket Metadata 000000011111";
		ticketMan.buyTicket(userS,eventID,meta);
		uint ticketID = uint(keccak256(abi.encodePacked(eventID,meta)));
		bytes32 _key = keccak256(abi.encodePacked(eventID,ticketID,"Event Ticket Owner"));
		Assert.equal(userS,mem.getAddress(_key),"Test Ticket Owner");
		_key = keccak256(abi.encodePacked(eventID,ticketID,"Event Ticket Ticket Metadata"));
		bytes32 m = keccak256(abi.encodePacked(meta));
		bytes32 _m = keccak256(abi.encodePacked(mem.getString(_key)));
		Assert.equal(m,_m,"Test Ticket Data");
	}

	function testBuyTicketTwice() external {
		ThrowProxy throwproxy = new ThrowProxy(address(ticketMan));
		TicketManager(address(throwproxy)).buyTicket(userS2,eventID,"Ticket Metadata 000000011111");
		bool r = throwproxy.execute.gas(200000)();
		Assert.equal(r,false,"Ticket is already active revert");
		uint ticketID = uint(keccak256(abi.encodePacked(eventID,"Ticket Metadata 000000011111")));
		bytes32 _key = keccak256(abi.encodePacked(eventID,ticketID,"Event Ticket Owner"));
		Assert.equal(userS,mem.getAddress(_key),"Actived ticket not recreated test");
	}

	function testBuyTicketNotTrading() external {
		ThrowProxy throwproxy = new ThrowProxy(address(ticketMan));
		TicketManager(address(throwproxy)).buyTicket(userS,eventID + 1,"Ticket Metadata");
		bool r = throwproxy.execute.gas(200000)();
		Assert.equal(r,false,"Revert event not in trading");
	}

	function ticketListingTest() external {
		uint ticketID = uint(keccak256(abi.encodePacked(eventID,"Ticket Metadata 000000011111")));
		ticketMan.listTicketForAuction(userS,eventID,ticketID,5);
		bytes32 _key = keccak256(abi.encodePacked(uint(0),"Auction ID Highest Bidder"));
		Assert.equal(userS,mem.getAddress(_key),"Test default highest bidder of auction");
		_key = keccak256(abi.encodePacked(uint(0),"Auction ID Highest Bid"));
		Assert.equal(uint(5),mem.getUint(_key),"Test default highest bidder of auction");
	}
}
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