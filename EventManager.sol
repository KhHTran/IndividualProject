pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract EventManager {
	IPMemory mem;
	address owner = msg.sender;

	modifier onlyOwner() {
		require(msg.sender == owner, "Not authorised");
		_;
	}

	function setContract(address m) external onlyOwner() {
		mem = IPMemory(m);
	}

	function getEventCount() internal view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked("Event Library Event Number Count"));
		return mem.getUint(crypt);
	}

	function setEventCount(uint val) internal {
		bytes32 crypt = keccak256(abi.encodePacked("Event Library Event Number Count"));
		mem.storeUint(crypt,val);
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

	function getTicketPrice(uint _eventID ) public view returns(uint) {
		bytes32 crypt = keccak256(abi.encodePacked(_eventID,"Ticket Price"));
		return mem.getUint(crypt);
	}

	function registerEvent(address _sender, string _name, string _url, uint _start, uint _end, uint _ticketPrice)
	external {
		require(isPrimary(_sender),"Only allowed for primary member");
		require(bytes(_name).length > 0 && bytes(_url).length > 0, "name and url cannot be empty");
		require(_ticketPrice > 0, "Ticket price is negative");
		require(_end > _start && _start > now, "Event time is not correct");
		bytes32 eventHash = keccak256(abi.encodePacked(_name,_url,_start,_end,_ticketPrice));
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Active Status"));
		require(mem.getUint(_key) == 0, "Event existed");
		mem.storeUint(_key,1);
		uint eventID = getEventCount();
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
		setEventCount(eventID + 1);
	}

	function cancelEvent(address _sender, uint _eventID) external {
		require(_sender == getEventOwner(_eventID), "Not authorised to cancel event");
		require(getEventStatus(_eventID) == 1, "Only allow cancel pending event");
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

	function getEventCloseTime(uint _eventID) public view returns(uint) {
		bytes32 _key = keccak256(abi.encodePacked(_eventID,"Event End"));
		return mem.getUint(_key);
	}

	function getEventStatus(uint _eventID) public view returns(uint) {
		uint currentTime = now;
		uint eventClose = getEventCloseTime(_eventID);
		uint eventStart = getEventOpenTime(_eventID);
		bytes32 _key = keccak256(abi.encodePacked(getEventHash(_eventID),"Event Active Status"));
		if (mem.getUint(_key) == 0) {
			return 0;
		}
		if (currentTime < eventStart) {
			return 1;
		}
		if (currentTime > eventClose) {
			return 3;
		}
		return 2;
	}

}