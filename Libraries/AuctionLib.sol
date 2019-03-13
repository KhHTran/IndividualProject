pragma solidity ^0.4.24;

import "./TicketLib.sol";
import "./IPMemory.sol";
import "./EventLib.sol";
import "./Token.sol";

library AuctionLib {
	enum AuctionStatus {Active, Ended, Closed}

	function setAuctionTimeLimit(uint lim, IPMemory mem) internal {
		bytes32 crypt = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		mem.storeUint(crypt,lim);
	}

	function getAuctionTimeLimit(IPMemory mem) public view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		return mem.getUint(crypt);
	}

	function getAuctionStatus(uint _auctionID, IPMemory mem) internal view returns(AuctionStatus) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Start Time"));
		uint _start = mem.getUint(crypt);
		uint current = now;
		uint auctionTime = getAuctionTimeLimit(mem);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		if(mem.getUint(crypt) == 0) {
			return AuctionStatus.Closed;
		}
		if(current > _start + auctionTime*24*3600) {
			return AuctionStatus.Ended;
		}
		return AuctionStatus.Active;
	}

	function listTicketForAuction(address _sender, uint _eventID, uint _ticketID, uint _minimumPrice, IPMemory mem) external {
		uint current = now;
		uint auctionTime = getAuctionTimeLimit(mem);
		require(!TicketLib.ticketListing(_eventID,_ticketID,mem), "Ticket is already in listing");
		require(EventLib.getEventStatus(_eventID,mem) == EventLib.EventStatus.Trading,"Event need to be in trading");
		require(TicketLib.ticketOwnership(_ticketID,_eventID,_sender,mem),"Sender is not ticket owner");
		require(_minimumPrice > 0 && _minimumPrice < EventLib.getTicketPrice(_eventID,mem), "Minimum price is not legal");
		require(current + auctionTime*24*3600 < EventLib.getEventCloseTime(_eventID,mem), "Not sufficient time for auction");
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,1);
		uint auctionID = TicketLib.getAuctionCount(mem);
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
		TicketLib.setAuctionCount(auctionID + 1,mem);
	}

	function placeBids(address _sender, uint _auctionID, uint _bid, Token token, IPMemory mem) external {
		require(getAuctionStatus(_auctionID,mem) == AuctionStatus.Active, "Auction no longer active");
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID,mem);
		uint maxPrice = EventLib.getTicketPrice(_eventID,mem);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID,mem);
		require(_bid < maxPrice, "Resell price can not be >= original price");
		require(_bid > currentPrice, "Resell price need to be > current bidding price");
		require(!TicketLib.ticketOwnership(_eventID,_ticketID,_sender,mem),"Owner cannot place bid");
		require(bidder != _sender, "Highest bidder cannot rebid");
		token.bookToken(_sender,_bid);
		token.freeBooking(bidder,currentPrice);
		bytes32 _key = keccak256(abi.encodePacked(_eventID,_ticketID,"Auction Highest Bidder"));
		mem.storeAddress(_key,_sender);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Auction Highest Bid"));
		mem.storeUint(_key,_bid);
	}

	function endAuction(address _sender, uint _auctionID, IPMemory mem) external {
		require(getAuctionStatus(_auctionID,mem) == AuctionStatus.Active, "Auction no longer active");
		(uint currentPrice, address bidder) = getAuctionData(_auctionID,mem);
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID,mem);
		require(bidder == _sender && TicketLib.ticketOwnership(_eventID,_ticketID,_sender,mem), "Only owner/bids were placed" );
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,0);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		mem.storeUint(crypt,0);
	}

	function finishAuction(address _sender, uint _auctionID, Token token, IPMemory mem) external {
		require(getAuctionStatus(_auctionID,mem) == AuctionStatus.Ended, "Auction not ended");
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID,mem);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID,mem);
		if(!TicketLib.ticketOwnership(_eventID,_ticketID,bidder,mem)) {
			require(_sender == bidder, "Only winner can close this auction");
			bytes32 crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
			address oldOwner = mem.getAddress(crypt);
			token.freeBooking(_sender,currentPrice);
			token.transfer(_sender,oldOwner,currentPrice);
			crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
			mem.storeAddress(crypt,_sender);
			crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
			mem.storeUint(crypt,0);
			crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
			mem.storeUint(crypt,0);
		}
		else {
			require(_sender == bidder, "Auction need to have no bids");
			crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
			mem.storeUint(crypt,0);
			crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
			mem.storeUint(crypt,0);
		}
	}
	
	function getAuctionEventTicket(uint _auctionID, IPMemory mem) internal view returns(uint,uint) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Event ID"));
		uint _eventID = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Ticket ID"));
		uint _ticketID = mem.getUint(crypt);
		return (_eventID,_ticketID);
	}
	
	function getAuctionData(uint _auctionID, IPMemory mem) internal view returns(uint,address) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bidder"));
		uint bid = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bid"));
		address bidder = mem.getAddress(crypt);
		return (bid,bidder);
	}
}