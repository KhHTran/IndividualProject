pragma solidity ^0.4.24;

import "./IPMemory.sol";
import "./Token.sol";
import "./EventLib.sol";
import "./TicketLib.sol";
import "./AuctionLib.sol";

library EventManagerLib {

	function registerEvent(address _sender, string _name, string _url, uint _start, uint _end, uint _price, IPMemory mem) external {
		EventLib.registerEvent(_sender,_name,_url,_start,_end,_price,mem);
	}

	function cancelEvent(address _sender, uint _eventID, IPMemory mem) external {
		EventLib.cancelEvent(_sender,_eventID,mem);
	}

	function buyTicket(address _sender, uint _eventID, string _metadata, IPMemory mem) external {
		TicketLib.buyTicket(_sender,_eventID,_metadata,mem);
	}

	function listTicketForAuction(address _sender, uint _eventID, uint _ticketID, uint _price, IPMemory mem) external {
		AuctionLib.listTicketForAuction(_sender,_eventID,_ticketID,_price,mem);
	}

	function placeBids(address _sender, uint _auctionID, uint _bid, Token token, IPMemory mem) external {
		AuctionLib.placeBids(_sender,_auctionID,_bid,token,mem);
	}

	function endAuction(address _sender, uint _auctionID, IPMemory mem) external {
		AuctionLib.endAuction(_sender,_auctionID,mem);
	}

	function finishAuction(address _sender, uint _auctionID, Token token, IPMemory mem) external {
		AuctionLib.finishAuction(_sender,_auctionID,token,mem);
	}

	function setAuctionTimeLimit(uint _day, IPMemory mem) external {
		AuctionLib.setAuctionTimeLimit(_day,mem);
	}
}