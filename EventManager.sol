pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "./Token.sol";
import "./EventManagerLib.sol";


contract EventManager {
	IPMemory mem;
	Token token;
	address owner = msg.sender;
	
	modifier onlyOwner() {
		require(owner == msg.sender, "Not authorised");
		_;
	}

	function setMemoryContract(address _memAddress) external onlyOwner() {
		mem = IPMemory(_memAddress);
	}

	function setTokenContract(address _tokenAddress) external onlyOwner() {
		token = Token(_tokenAddress);
	}

	function registerEvent(address _sender, string _name, string _url, uint _start, uint _end, uint _price) external {
		EventManagerLib.registerEvent(_sender,_name,_url,_start,_end,_price,mem);
	}

	function cancelEvent(address _sender, uint _eventID) external {
		EventManagerLib.cancelEvent(_sender,_eventID,mem);
	}

	function buyTicket(address _sender, uint _eventID, string _metadata) external {
		EventManagerLib.buyTicket(_sender,_eventID,_metadata,mem);
	}

	function listTicketForAuction(address _sender, uint _eventID, uint _ticketID, uint _price) external {
		EventManagerLib.listTicketForAuction(_sender,_eventID,_ticketID,_price,mem);
	}

	function placeBids(address _sender, uint _auctionID, uint _bid) external {
		EventManagerLib.placeBids(_sender,_auctionID,_bid,token,mem);
	}

	function endAuction(address _sender, uint _auctionID) external {
		EventManagerLib.endAuction(_sender,_auctionID,mem);
	}

	function finishAuction(address _sender, uint _auctionID) external {
		EventManagerLib.finishAuction(_sender,_auctionID,token,mem);
	}

	function setAuctionTimeLimit(uint _day) external onlyOwner() {
		EventManagerLib.setAuctionTimeLimit(_day,mem);
	}
}