pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "./EventManager.sol";

contract TicketManager {
	IPMemory mem;
	EventManager eventMan;
	address owner = msg.sender;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}

	function setContract(address me, address eve) external onlyOwner() {
		mem = IPMemory(me);
		eventMan = EventManager(eve);
	}

	function getAuctionCount() internal view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Ticket Library Auction Number Count"));
		return mem.getUint(crypt);
	}

	function setAuctionCount(uint val) internal {
		bytes32 crypt = keccak256(abi.encodePacked("Ticket Library Auction Number Count"));
		mem.storeUint(crypt,val);
	}

	function ticketOwnership(uint _eventID, uint _ticketID, address _owner) public view returns(bool) {
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Owner"));
		return _owner == mem.getAddress(crypt);
	}

	function activeTicket(uint _eventID, uint _ticketID) internal view returns(bool) {
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		return mem.getUint(_key) == 1;
	}

	function buyTicket(address _sender, uint _eventID, string _ticketData) external 
	{
	    bytes32 crypt = keccak256(abi.encodePacked(_sender,"Secondary"));
		require(eventMan.getEventStatus(_eventID) == 2,"Event need to be in trading");
		require(mem.getUint(crypt) == 1,"Buyer is not registered");
		uint _ticketID = uint(keccak256(abi.encodePacked(_eventID,_ticketData)));
		require(!activeTicket(_eventID,_ticketID),"ticket is already active");
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		mem.storeUint(_key,1);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Owner"));
		mem.storeAddress(_key,_sender);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Ticket Metadata"));
		mem.storeString(_key,_ticketData);
	}
	
	function ticketListing(uint _eventID, uint _ticketID) internal view returns(bool) {
		require(eventMan.getEventStatus(_eventID) == 2,"Event need to be in trading");
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		return mem.getUint(crypt) != 0;
	}

	function listTicketForAuction(address _sender, uint _eventID, uint _ticketID, uint _minimumPrice) external {
		uint current = now;
		bytes32 c = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		uint auctionTime = mem.getUint(c);
		require(!ticketListing(_eventID,_ticketID), "Ticket is already in listing");
		require(eventMan.getEventStatus(_eventID) == 2,"Event need to be in trading");
		require(ticketOwnership(_eventID,_ticketID,_sender),"Sender is not ticket owner");
		require(_minimumPrice > 0 && _minimumPrice < eventMan.getTicketPrice(_eventID), "Minimum price is not legal");
		require(current + auctionTime*3600 < eventMan.getEventCloseTime(_eventID), "Not sufficient time for auction");
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,1);
		uint auctionID = getAuctionCount();
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Highest Bidder"));
		mem.storeAddress(crypt,_sender);
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Highest Bid"));
		mem.storeUint(crypt,_minimumPrice);
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Start Time"));
		mem.storeUint(crypt,current);
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Active Status"));
		mem.storeUint(crypt,1);
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Event ID"));
		mem.storeUint(crypt,_eventID);
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Ticket ID"));
		mem.storeUint(crypt,_ticketID);
		setAuctionCount(auctionID + 1);
	}
}