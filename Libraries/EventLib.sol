pragma solidity ^0.4.24;

import "./IPMemory.sol";

library EventLib {
	enum EventStatus {Pending, Trading, Closed, NonExist}

	function getEventCount(IPMemory mem) internal view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Event Library Event Number Count"));
		return mem.getUint(crypt);
	}

	function setEventCount(uint val, IPMemory mem) internal {
		bytes32 crypt = keccak256(abi.encodePacked("Event Library Event Number Count"));
		mem.storeUint(crypt,val);
	}

	function encrypt(address _address, string _string) internal pure returns(bytes32) {
		return keccak256(abi.encodePacked(_address,_string));
	}

	function isPrimary(address _member, IPMemory mem) internal view returns(bool) {
		bytes32 _key = encrypt(_member,'Primary');
		return mem.getUint(_key) != 0;
	}

	function getEventHash(uint _eventID, IPMemory mem) internal view returns(bytes32) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Hash"));
		return mem.getBytes32(_key);
	}

	function getTicketPrice(uint _eventID, IPMemory mem) public view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,"Ticket Price"));
		return mem.getUint(crypt);
	}

	function registerEvent(address _sender, string _name, string _url, uint _start, uint _end, uint _ticketPrice, IPMemory mem)
	external {
		require(isPrimary(_sender,mem),"Only allowed for primary member");
		require(bytes(_name).length > 0 && bytes(_url).length > 0, "name and url cannot be empty");
		require(_ticketPrice < 0, "Ticket price is negative");
		require(_end > _start && _start > now, "Event time is not correct");
		bytes32 eventHash = keccak256(abi.encodePacked(_name,_url,_start,_end,_ticketPrice));
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		require(mem.getUint(_key) == 0, "Event existed");
		mem.storeUint(_key,1);
		uint eventID = getEventCount(mem);
		_key = keccak256(abi.encodePacked(eventID,"Event Start"));
		mem.storeUint(_key,_start);
		_key = keccak256(abi.encodePacked(eventID,"Event End"));
		mem.storeUint(_key,_end);
		_key = keccak256(abi.encodePacked(eventID,"Ticket Price"));
		mem.storeUint(_key,_ticketPrice);
		_key = keccak256(abi.encodePacked(eventID,"Event Owner"));
		mem.storeAddress(_key,_sender);
		_key = keccak256(abi.encodePacked(eventID,"Event Hash"));
		mem.storeBytes32(_key,eventHash);
		setEventCount(eventID + 1, mem);
	}

	function cancelEvent(address _sender, uint _eventID, IPMemory mem) external {
		require(_sender == getEventOwner(_eventID,mem), "Not authorised to cancel event");
		require(getEventStatus(_eventID,mem) == EventStatus.Pending, "Only allow cancel pending event");
		bytes32 eventHash = getEventHash(_eventID,mem);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		mem.storeUint(_key,0);
	}

	function getEventOwner(uint _eventID, IPMemory mem) internal view returns(address) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Owner"));
		return mem.getAddress(_key);
	}

	function getEventOpenTime(uint _eventID, IPMemory mem) internal view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event Start"));
		return mem.getUint(_key);
	}

	function getEventCloseTime(uint _eventID, IPMemory mem) public view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event End"));
		return mem.getUint(_key);
	}

	function getEventStatus(uint _eventID, IPMemory mem) public view returns(EventStatus) {
		uint currentTime = now;
		uint eventClose = getEventCloseTime(_eventID,mem);
		bytes32 _key = keccak256(abi.encodePacked(getEventHash(_eventID,mem),"Event Active Status"));
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
}