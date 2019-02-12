pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract EventManager {
	enum EventStatus {Pending, Trading, Closed, NonExist};
	uint count = 0;
	IPMemory mem;
	address owner = msg.sender;
	modifier onlyOwner() {
		require(owner == msg.sender, "Not authorised")
	}

	modifier onlyInTrading(uint _eventID) {
		require(getEventStatus(_eventID) == Trading, "Event is not in trading");
		_;
	}

	modifier eventExist(uint _eventID) {
		require(getEventStatus(_eventID) != NonExist, "Event does not exist");
		_;
	}

	modifier eventStillPending(uint _eventID) {
		require(getEventStatus(_eventID) == Pending, "Event is not in pending");
		_;
	}

	modifier TicketIsActive(uint _eventID, uint _ticketID) {
		require(activeTicket(_eventID,_ticketID), "Ticket for event is not active");
		_;
	}

	function setMemoryContract(address _memAddress) external onlyOwner() {
		mem = IPMemory(_memAddress);
	}

	function encrypt(address _address, string _string) internal returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string));
	}

	function registerEvent(string _name, string _url, uint _start, uint _end, uint _ticketPrice, bytes _signature) 
	external {
		require(_start < _end, "the ticket sale end must be later than the begining");
		bytes32 eventHash = keccak256(abi.encodePacked(_name,_url,_start,_end,_ticketPrice));
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		require(mem.getUint(_key) == 0, "Event existed");
		mem.storeUint(_key,1);
		eventID = count + 1;
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Event Start"));
		mem.storeUint(_key,_start);
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Event End"));
		mem.storeUint(_key,_end);
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Ticket Price"));
		mem.storeUint(_key,_ticketPrice);
		address eventOwner = getSigner(eventHash, _signature);
		require(eventOwner != address(0), "Address can not be extracted from signature");
		require(mem.getUint(eventOwner,"Primary") != 0, "Event owner must be primary member");
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Event Owner"));
		count += 1;
		mem.storeAddress(_key,eventOwner);
		_key = keccak256(abi.encodePacked(eventID,"Event Hash"));
		mem.storeBytes32(_key,eventHash);
	}

	function getEventOwner(uint _eventID) internal returns(address) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Owner"));
		return mem.getAddress(_key);
	}

	function getEventOpenTime(uint _eventID) internal returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Event Start"));
		return mem.getUint();
	}

	function getEventCloseTime(uint _eventID) internal returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(eventID,"Event End"));
		return mem.getUint();	
	}

	function getEventStatus(uint _eventID) internal returns(EventStatus) {
		uint currentTime = now;
		bytes32 _key = keccak256(abi.encodePacked(mem.getBytes32(_eventID,"Event Hash"),"Event Active Status"));
		if (mem.getUint(_key) == 0) {
			return NonExist;
		}
		if (currentTime < getEventOpenTime()) {
			return Pending;
		}
		if (currentTime > getEventCloseTime()) {
			return Closed;
		}
		return Trading;
	}

	function activeTicket(uint _eventID, uint _ticketID) internal returns(bool) {
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		return mem.getUint(_key) == 1;
	}

	function sellTicket(uint _eventID, address _buyer, string _ticketData, bytes _signature) external 
	eventStillPending(_eventID) {
		require(mem.getUint(_buyer,"Secondary") == 1,"Buyer is not registered");
		bytes32 _hash = keccak256(abi.encodePacked(_eventID,_buyer,_ticketData));
		address eventOwner = getSigner(_hash,_signature);
		uint _ticketID = uint(keccak256(abi.encodePacked(_eventID,eventOwner,_ticketData)));
		require(!activeTicket(_eventID,_ticketID),"ticket is already active");
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		mem.storeUint(_key,1);
		_key = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
		mem.storeAddress(_key,_buyer);
	}

	function getSigner(bytes32 _hash, bytes _signature) internal returns(address) {
		bytes32 ethSigned = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
		if (ethSigned.length != 65) {
			return address(0);
		}
		bytes32 _r;
		bytes32 _s;
		uint8 _v;
		assembly {
			_r := mload(add(_signature, 32))
			_s := mload(add(_signature, 64))
			_v := byte(0, mload(add(_signature, 96)))
		}
		if (_v < 27) {
			_v += 27;
		}
		require(_v == 27 || _v == 28, "Incorrect signature version");
		return ecrecover(ethSigned,_v,_r,_s);
	}
}