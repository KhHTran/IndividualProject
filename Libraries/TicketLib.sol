pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "./EventLib.sol";

library TicketLib {
	function getAuctionCount(IPMemory mem) internal view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Ticket Library Auction Number Count"));
		return mem.getUint(crypt);
	}

	function setAuctionCount(uint val, IPMemory mem) internal {
		bytes32 crypt = keccak256(abi.encodePacked("Ticket Library Auction Number Count"));
		mem.storeUint(crypt,val);
	}

	function ticketOwnership(uint _eventID, uint _ticketID, address _owner, IPMemory mem) public view returns(bool) {
		bytes32 crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
		return _owner == mem.getAddress(crypt);
	}

	function activeTicket(uint _eventID, uint _ticketID, IPMemory mem) internal view returns(bool) {
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		return mem.getUint(_key) == 1;
	}

	function buyTicket(address _sender, uint _eventID, string _ticketData, IPMemory mem) external 
	{
	    bytes32 crypt = keccak256(abi.encodePacked(_sender,"Secondary"));
		require(EventLib.getEventStatus(_eventID,mem) == EventLib.EventStatus.Trading,"Event need to be in trading");
		require(mem.getUint(crypt) == 1,"Buyer is not registered");
		uint _ticketID = uint(keccak256(abi.encodePacked(_eventID,_ticketData)));
		require(!activeTicket(_eventID,_ticketID,mem),"ticket is already active");
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		mem.storeUint(_key,1);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Owner"));
		mem.storeAddress(_key,_sender);
	}
	
	function ticketListing(uint _eventID, uint _ticketID, IPMemory mem) internal view returns(bool) {
		require(EventLib.getEventStatus(_eventID,mem) == EventLib.EventStatus.Trading,"Event need to be in trading");
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		return mem.getUint(crypt) != 0;
	}
}