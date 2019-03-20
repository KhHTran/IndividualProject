pragma solidity ^0.4.24;

import "./TicketManager.sol";
import "./IPMemory.sol";
import "./EventManager.sol";
import "./Token.sol";

contract AuctionManager {
	enum AuctionStatus {Active, Ended, Closed}

	address owner = msg.sender;
	IPMemory mem;
	EventManager eventMan;
	TicketManager ticketMan;
	Token token;

	modifier onlyOwner() {
		require(msg.sender == owner,"Not authorised");
		_;
	}

	function setContract(address m, address e, address t, address to) external onlyOwner() {
		mem = IPMemory(m);
		eventMan = EventManager(e);
		ticketMan = TicketManager(t);
		token = Token(to);
		bytes32 crypt = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		mem.storeUint(crypt,uint(2));
	}

	function setAuctionTimeLimit(uint lim) external onlyOwner {
		bytes32 crypt = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		mem.storeUint(crypt,lim);
	}

	function getAuctionTimeLimit() public view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Auction Library Auction Time Limit"));
		return mem.getUint(crypt);
	}

	function getAuctionStatus(uint _auctionID) internal view returns(AuctionStatus) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Start Time"));
		uint _start = mem.getUint(crypt);
		uint current = now;
		uint auctionTime = getAuctionTimeLimit();
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		if(mem.getUint(crypt) == 0) {
			return AuctionStatus.Closed;
		}
		if(current > _start + auctionTime*3600) {
			return AuctionStatus.Ended;
		}
		return AuctionStatus.Active;
	}

	function placeBids(address _sender, uint _auctionID, uint _bid) external {
		require(getAuctionStatus(_auctionID) == AuctionStatus.Active, "Auction no longer active");
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		uint maxPrice = eventMan.getTicketPrice(_eventID);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID);
		require(_bid < maxPrice, "Resell price can not be >= original price");
		require(_bid > currentPrice, "Resell price need to be > current bidding price");
		require(!ticketMan.ticketOwnership(_eventID,_ticketID,_sender),"Owner cannot place bid");
		require(bidder != _sender, "Highest bidder cannot rebid");
		token.bookToken(_sender,_bid);
		if(!ticketMan.ticketOwnership(_eventID,_ticketID,bidder)) {
			token.freeBooking(bidder,currentPrice);
		}
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bidder"));
		mem.storeAddress(crypt,_sender);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bid"));
		mem.storeUint(crypt,_bid);
	}

	function endAuction(address _sender, uint _auctionID) external {
		require(getAuctionStatus(_auctionID) == AuctionStatus.Active, "Auction no longer active");
		(uint currentPrice, address bidder) = getAuctionData(_auctionID);
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		require(bidder == _sender || ticketMan.ticketOwnership(_eventID,_ticketID,_sender), "Only owner/bids were placed" );
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,0);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		mem.storeUint(crypt,0);
	}

	function finishAuction(address _sender, uint _auctionID) external {
		require(getAuctionStatus(_auctionID) == AuctionStatus.Ended, "Auction not ended");
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID);
		if(!ticketMan.ticketOwnership(_eventID,_ticketID,bidder)) {
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
	
	function getAuctionEventTicket(uint _auctionID) internal view returns(uint,uint) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Event ID"));
		uint _eventID = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Ticket ID"));
		uint _ticketID = mem.getUint(crypt);
		return (_eventID,_ticketID);
	}
	
	function getAuctionData(uint _auctionID) internal view returns(uint,address) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bid"));
		uint bid = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bidder"));
		address bidder = mem.getAddress(crypt);
		return (bid,bidder);
	}
}