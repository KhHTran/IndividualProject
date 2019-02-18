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

	modifier onlyPrimary() {
		require(msg.sender == owner || isPrimary(msg.sender), "Not authorised for non Primary Member");
		_;
	}
	modifier eventInTrading(uint _eventID) {
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

	modifier legalEventTime(uint _start, uint _end) {
		uint current = now;
		require(current < _start && _start < _end, "Event start need to be in the future and end after start");
		_;
	}

	function setMemoryContract(address _memAddress) external onlyOwner() {
		mem = IPMemory(_memAddress);
	}

	function encrypt(address _address, string _string) internal returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string));
	}

	function isPrimary(address _member) internal returns(bool) {
		bytes32 _key = encrypt(_member,'Primary');
		return mem.getUint(_key) != 0;
	}

	function getEventHash(uint _eventID) internal returns(bytes32) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Hash"));
		return mem.getBytes32(_key);
	}

	function registerEvent(string _name, string _url, uint _start, uint _end, uint _ticketPrice, bytes _signature)
	external onlyPrimary() legalEventTime(_start,_end) {
		require(bytes(_name).length > 0, "Name length is 0");
		require(bytes(_url).length > 0, "URL length is 0");
		require(_ticketPrice < 0, "Ticket price is negative");
		bytes32 eventHash = keccak256(abi.encodePacked(_name,_url,_start,_end,_ticketPrice));
		address signer = getSigner(eventHash,_signature);
		require(msg.sender == signer, "Signer is not sender");
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		require(mem.getUint(_key) == 0, "Event existed");
		mem.storeUint(_key,1);
		count += 1;
		eventID = count;
		_key = keccak256(abi.encodePacked(eventID,"Event Start"));
		mem.storeUint(_key,_start);
		_key = keccak256(abi.encodePacked(eventID,"Event End"));
		mem.storeUint(_key,_end);
		_key = keccak256(abi.encodePacked(eventID,"Ticket Price"));
		mem.storeUint(_key,_ticketPrice);
		_key = keccak256(abi.encodePacked(eventID,"Event Owner"));
		mem.storeAddress(_key,eventOwner);
		_key = keccak256(abi.encodePacked(eventID,"Event Hash"));
		mem.storeBytes32(_key,eventHash);
	}

	function cancelEvent(uint _eventID) external onlyPrimary() eventStillPending(eventID) {
		require(msg.sender == owner || msg.sender == getEventOwner(_eventID), "Not authorised to cancel event");
		bytes32 eventHash = getEventHash(_eventID);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		mem.storeUint(_key,0);
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
		bytes32 _key = keccak256(abi.encodePacked(getEventHash(_eventID),"Event Active Status"));
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

	function buyTicket(uint _eventID, string _ticketData, bytes _signature) external 
	eventInTrading(_eventID)
	{
		require(mem.getUint(msg.sender,"Secondary") == 1,"Buyer is not registered");
		uint _ticketID = uint(keccak256(abi.encodePacked(_eventID,msg.sender,_ticketData)));
		bytes ticketHash = keccak256(abi.encodePacked(_eventID,_ticketData));
		address signer = getSigner(ticketHash, _signature);
		require(msg.sender == signer, "Signer is not sender");
		require(!activeTicket(_eventID,_ticketID),"ticket is already active");
		bytes32 _key = keccak256(abi.encodePacked("Event-Ticket",_eventID,_ticketID));
		mem.storeUint(_key,1);
		_key = keccak256(abi.encodePacked("Event Ticket Owner",_eventID,_ticketID));
		mem.storeAddress(_key,msg.sender);
	}

	function getSigner(bytes32 _hash, bytes _signature) internal returns(address) {
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