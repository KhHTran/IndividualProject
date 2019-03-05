pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "./Token.sol";

contract EventManager {
	enum EventStatus {Pending, Trading, Closed, NonExist}
	enum AuctionStatus {Active, Closed, Ended}
	uint countEvent = 0;
	uint countAuction = 0;
	IPMemory mem;
	Token token;
	address owner = msg.sender;
	uint auctionTime = 3;

	modifier onlyOwner() {
		require(owner == msg.sender, "Not authorised");
		_;
	}

	modifier onlyPrimary() {
		require(msg.sender == owner || isPrimary(msg.sender), "Not authorised for non Primary Member");
		_;
	}
	modifier eventInTrading(uint _eventID) {
		require(getEventStatus(_eventID) == EventStatus.Trading, "Event is not in trading");
		_;
	}

	modifier eventExist(uint _eventID) {
		require(getEventStatus(_eventID) != EventStatus.NonExist, "Event does not exist");
		_;
	}

	modifier eventStillPending(uint _eventID) {
		require(getEventStatus(_eventID) == EventStatus.Pending, "Event is not in pending");
		_;
	}

	modifier TicketIsActive(uint _eventID, uint _ticketID) {
		require(activeTicket(_eventID,_ticketID), "Ticket for event is not active");
		_;
	}

	modifier ticketInListing(uint _eventID, uint _ticketID) {
		require(ticketListed(_eventID,_ticketID),"Ticket is not listed");
		_;
	}

	modifier ticketNotListed(uint _eventID, uint _ticketID) {
		require(!ticketListed(_eventID,_ticketID),"Ticket already listed");
		_;
	}

	modifier legalEventTime(uint _start, uint _end) {
		uint current = now;
		require(current < _start && _start < _end, "Event start need to be in the future and end after start");
		_;
	}
	
	modifier auctionStillOpen(uint _auctionID) {
	    require(getAuctionStatus(_auctionID) == AuctionStatus.Active, "auction no longer open");
	    _;
	}
	
	modifier auctionOwner(uint _auctionID) {
	    (uint _eventID,uint _ticketID) = getAuctionEventTicket(_auctionID);
	    require(ticketOwnership(_eventID,_ticketID,msg.sender),"only auctionOwner authorised");
	    _;
	}
	
	modifier noBidPlaced(uint _auctionID) {
	    (uint bid, address bidder) = getAuctionData(_auctionID);
	    (uint _eventID,uint _ticketID) = getAuctionEventTicket(_auctionID);
	    require(!ticketOwnership(_eventID,_ticketID,bidder),"Bids were placed");
	    _;
	}

	function setMemoryContract(address _memAddress) external onlyOwner() {
		mem = IPMemory(_memAddress);
	}

	function setTokenContract(address _tokenAddress) external onlyOwner() {
		token = Token(_tokenAddress);
	}

	function setAuctionTimeLimit(uint _day) external onlyOwner() {
		require(_day > 1, "Auction need at least a _day");
		auctionTime = _day;
	}

	function encrypt(address _address, string _string) internal pure returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string));
	}

	function isPrimary(address _member) internal view returns(bool) {
		bytes32 _key = encrypt(_member,'Primary');
		return mem.getUint(_key) != 0;
	}

	function getEventHash(uint _eventID) internal view returns(bytes32) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Hash"));
		return mem.getBytes32(_key);
	}

	function ticketOwnership(uint _eventID, uint _ticketID, address _owner) internal view returns(bool) {
		bytes32 crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
		return _owner == mem.getAddress(crypt);
	}

	function getTicketPrice(uint _eventID) internal view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,"Ticket Price"));
		return mem.getUint(crypt);
	}

	function registerEvent(string _name, string _url, uint _start, uint _end, uint _ticketPrice, bytes _signature)
	external onlyPrimary() legalEventTime(_start,_end) {
		
		require(_ticketPrice < 0, "Ticket price is negative");
		bytes32 eventHash = keccak256(abi.encodePacked(_name,_url,_start,_end,_ticketPrice));
		address signer = getSigner(eventHash,_signature);
		require(msg.sender == signer, "Signer is not sender");
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		require(mem.getUint(_key) == 0, "Event existed");
		mem.storeUint(_key,1);
		countEvent += 1;
		uint eventID = countEvent;
		_key = keccak256(abi.encodePacked(eventID,"Event Start"));
		mem.storeUint(_key,_start);
		_key = keccak256(abi.encodePacked(eventID,"Event End"));
		mem.storeUint(_key,_end);
		_key = keccak256(abi.encodePacked(eventID,"Ticket Price"));
		mem.storeUint(_key,_ticketPrice);
		_key = keccak256(abi.encodePacked(eventID,"Event Owner"));
		mem.storeAddress(_key,msg.sender);
		_key = keccak256(abi.encodePacked(eventID,"Event Hash"));
		mem.storeBytes32(_key,eventHash);
	}

	function cancelEvent(uint _eventID) external onlyPrimary() eventStillPending(_eventID) {
		require(msg.sender == owner || msg.sender == getEventOwner(_eventID), "Not authorised to cancel event");
		bytes32 eventHash = getEventHash(_eventID);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		mem.storeUint(_key,0);
	}

	function getEventOwner(uint _eventID) internal view returns(address) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Owner"));
		return mem.getAddress(_key);
	}

	function getEventOpenTime(uint _eventID) internal view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Start"));
		return mem.getUint(_key);
	}

	function getEventCloseTime(uint _eventID) internal view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event End"));
		return mem.getUint(_key);
	}

	function getEventStatus(uint _eventID) internal view returns(EventStatus) {
		uint currentTime = now;
		uint eventClose = getEventCloseTime(_eventID);
		bytes32 _key = keccak256(abi.encodePacked(getEventHash(_eventID),"Event Active Status"));
		if (mem.getUint(_key) == 0) {
			return EventStatus.NonExist;
		}
		if (currentTime < eventClose) {
			return EventStatus.Pending;
		}
		if (currentTime > eventClose) {
			return EventStatus.Closed;
		}
		return EventStatus.Trading;
	}

	function activeTicket(uint _eventID, uint _ticketID) internal view returns(bool) {
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		return mem.getUint(_key) == 1;
	}

	function buyTicket(uint _eventID, string _ticketData, bytes _signature) external 
	eventInTrading(_eventID)
	{
		require(mem.getUint(encrypt(msg.sender,"Secondary")) == 1,"Buyer is not registered");
		uint _ticketID = uint(keccak256(abi.encodePacked(_eventID,_ticketData)));
		bytes32 ticketHash = keccak256(abi.encodePacked(_eventID,_ticketData));
		address signer = getSigner(ticketHash, _signature);
		require(msg.sender == signer, "Signer is not sender");
		require(!activeTicket(_eventID,_ticketID),"ticket is already active");
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		mem.storeUint(_key,1);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Owner"));
		mem.storeAddress(_key,msg.sender);
	}
	
	function ticketListed(uint _eventID, uint _ticketID) internal view returns(bool) {
	    bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
	    return mem.getUint(crypt) != 0;
	}

	function listTicketForAuction(uint _eventID, uint _ticketID, uint _minimumPrice, bytes _signature) external
	eventInTrading(_eventID) 
	ticketNotListed(_eventID,_ticketID) {
		bytes32 listHash = keccak256(abi.encodePacked(_ticketID,_eventID));
		address signer = getSigner(listHash,_signature);
		uint current = now;
		require(signer == msg.sender, "Signer is not sender");
		require(ticketOwnership(_ticketID,_eventID,msg.sender),"Sender is not ticket owner");
		require(_minimumPrice > 0 && _minimumPrice < getTicketPrice(_eventID), "Minimum price is not legal");
		require(current + auctionTime*24*3600 < getEventCloseTime(_eventID), "Not sufficient time for auction");
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,1);
		uint auctionID = countAuction;
		crypt = keccak256(abi.encodePacked(auctionID,"Auction ID Highest Bidder"));
		mem.storeAddress(crypt,msg.sender);
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
		countAuction += 1;
	}
	
	function getAuctionStatus(uint _auctionID) internal view returns(AuctionStatus) {
		bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Start Time"));
		uint _start = mem.getUint(crypt);
		uint current = now;
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		if(mem.getUint(crypt) == 0) {
			return AuctionStatus.Closed;
		}
		if(current > _start + auctionTime*24*3600) {
			return AuctionStatus.Ended;
		}
		return AuctionStatus.Active;
	}

	function placeBids(uint _auctionID, uint _bid) external auctionStillOpen(_auctionID) {
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		uint maxPrice = getTicketPrice(_eventID);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID);
		require(_bid < maxPrice, "Resell price can not be >= original price");
		require(_bid > currentPrice, "Resell price need to be > current bidding price");
		require(!ticketOwnership(_eventID,_ticketID,msg.sender),"Owner cannot place bid");
		require(bidder != msg.sender, "Highest bidder cannot rebid");
		token.bookToken(_bid);
		bytes32 _key = keccak256(abi.encodePacked(_eventID,_ticketID,"Auction Highest Bidder"));
		mem.storeAddress(_key,msg.sender);
		_key = keccak256(abi.encodePacked(_eventID,_ticketID,"Auction Highest Bid"));
		mem.storeUint(_key,_bid);
	}

	function endAuction(uint _auctionID) external auctionOwner(_auctionID) noBidPlaced(_auctionID) {
	    (uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
		mem.storeUint(crypt,0);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
		mem.storeUint(crypt,0);
	}

	function finishAuction(uint _auctionID) external auctionStillOpen(_auctionID) {
		(uint _eventID, uint _ticketID) = getAuctionEventTicket(_auctionID);
		(uint currentPrice, address bidder) = getAuctionData(_auctionID);
		if(!ticketOwnership(_eventID,_ticketID,bidder)) {
			require(msg.sender == bidder, "Only winner can close this auction");
			bytes32 crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
			address oldOwner = mem.getAddress(crypt);
			token.transfer(oldOwner,currentPrice);
			token.freeBooking(msg.sender,currentPrice);
			crypt = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
			mem.storeAddress(crypt,msg.sender);
			crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
			mem.storeUint(crypt,0);
			crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
			mem.storeUint(crypt,0);
		}
		else {
			require(msg.sender == bidder, "Only ticket owner can close this auction");
			crypt = keccak256(abi.encodePacked(_eventID,_ticketID,"Ticket Event In Listing"));
			mem.storeUint(crypt,0);
			crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Active Status"));
			mem.storeUint(crypt,0);
		}
	}
	
	function getAuctionEventTicket(uint _auctionID) internal view auctionStillOpen(_auctionID) returns(uint,uint) {
	    bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Event ID"));
		uint _eventID = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Ticket ID"));
		uint _ticketID = mem.getUint(crypt);
		return (_eventID,_ticketID);
	}
	
	function getAuctionData(uint _auctionID) internal view auctionStillOpen(_auctionID) returns(uint,address) {
	    bytes32 crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bidder"));
		uint bid = mem.getUint(crypt);
		crypt = keccak256(abi.encodePacked(_auctionID,"Auction ID Highest Bid"));
		address bidder = mem.getAddress(crypt);
		return (bid,bidder);
	}

	function getSigner(bytes32 _hash, bytes _signature) internal pure returns(address) {
		bytes32 _ethSigned = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
		bytes32 r;
		bytes32 s;
		uint8 v;
		if(_signature.length != 65) {
			return address(0);
		}
		assembly {
			r := mload(add(_signature,32))
			s := mload(add(_signature,64))
			v := byte(0, mload(add(_signature, 96)))
		}
		if(v < 27) {
			v += 27;
		}
		require(v == 27 || v == 28, "Illegal signature version");
		return ecrecover(_ethSigned,v,r,s);
	}
}