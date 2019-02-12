pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract EventManager {

	IPMemory mem;
	address owner = msg.sender;
	modifier onlyOwner() {
		require(owner == msg.sender, "Not authorised")
	}

	modifier memberIsPrime() {
		bytes32 crypt = encrypt(msg.sender,"Primary");
		require(mem.getUint(crypt) > 0 || msg.sender == owner,"not a primary member");
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
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Hash"));
		require(mem.getUint(_key) == 0, "Event hash existed");
		mem.storeUint(_key,1);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Start"));
		mem.storeUint(_key,_start);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event End"));
		mem.storeUint(_key,_end);
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Ticket Price"));
		mem.storeUint(_key,_ticketPrice);
		address eventOwner = getSigner(eventHash, _signature);
		require(eventOwner != address(0), "Address can not be extracted from signature");
		bytes32 _key = keccak256(abi.encodePacked(eventHash,"Event Owner"));
		mem.storeAddress(_key,eventOwner);
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