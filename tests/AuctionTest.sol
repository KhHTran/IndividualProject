pragma solidity ^0.4.24;

import "remix_tests.sol";
import "./IPMemory.sol";
import "./EventManager.sol";
import "./TicketManager.sol";
import "./AuctionManager.sol";
import "./Token.sol";

contract AuctionTest {
	IPMemory mem;
	EventManager eventM;
	TicketManager ticketM;
	AuctionManager auctionM;
	Token token;
	address primary = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
	address owner = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
	address buyer = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
	uint eventID = 0;
	uint auctionID = 0;
	uint ticketID;

	constructor(address m, address e, address t, address a, address to) public {
		mem = IPMemory(m);
		eventM = EventManager(e);
		ticketM = TicketManager(t);
		auctionM = AuctionManager(a);
		token = Token(to);
		bytes32 crypt = keccak256(abi.encodePacked(primary,"Primary"));
		mem.storeUint(crypt,1);
		uint current = now;
		eventM.registerEvent(primary,"Event Example","testurl",now + 5,now + 100000,100);
		crypt = keccak256(abi.encodePacked(owner,"Secondary"));
		mem.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(buyer,"Secondary"));
		mem.storeUint(crypt,1);
		token.deposit(owner,200);
		token.deposit(buyer,200);
		while(now < current + 7) {
		}
		string memory meta = "Ticket Metadata 1234567890";
		ticketM.buyTicket(owner,eventID,meta);
		ticketID = uint(keccak256(abi.encodePacked(eventID,meta)));
		ticketM.listTicketForAuction(owner,eventID,ticketID,50);
	}

	function test1() external {
		// Test for end auction
		ThrowProxy throwproxy = new ThrowProxy(address(auctionM));
		AuctionManager(address(throwproxy)).endAuction(buyer,auctionID);
		bool r = throwproxy.execute.gas(200000)();
		Assert.equal(r,false,"Test end auction revert. Not owner of ticket");

		auctionM.endAuction(owner,auctionID);
		bytes32 crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Active Status"));
		Assert.equal(mem.getUint(crypt),uint(0),"Test auction active status");
		crypt = keccak256(abi.encodePacked(eventID,ticketID,"Ticket Event In Listing"));
		Assert.equal(mem.getUint(crypt),uint(0),"Test listing status of ticket");
	}

	function test2() external {		ticketM.listTicketForAuction(owner,eventID,ticketID);
		ThrowProxy throwproxy = new ThrowProxy(address(auctionM));
		AuctionManager(address(throwproxy)).placeBids(owner,auctionID,80);
		bool r = throwproxy.execute.gas(200000)();
		Assert.equal(r,false,"Owner bid for auction revert");
		AuctionManager(address(throwproxy)).placeBids(buyer,auctionID,40);
		bool r = throwproxy.execute.gas(200000)();
		Assert.equal(r,false,"bid not high enough auction revert");
		ticketM.placeBids(buyer,auctionID,60);
		bytes32 _key = keccak256(abi.encodePacked(auctionID,"Auction ID Highest Bidder"));
		Assert.equal(buyer,mem.getAddress(_key),"Test default highest bidder of auction");
		_key = keccak256(abi.encodePacked(auctionID,"Auction ID Highest Bid"));
		Assert.equal(uint(60),mem.getUint(_key),"Test default highest bidder of auction");
		Assert.equal(token.getTotalBooking(buyer),uint(60),"Test booking after bid");
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