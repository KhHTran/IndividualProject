pragma solidity ^0.4.24;

import "./IPMemory.sol";

contract Verification {
    IPMemory mem;
    address owner = msg.sender;
    
    function setContract(address _mem) external {
        require(msg.sender == owner, "Not Authorised");
        mem = IPMemory(_mem);
    }
    
    function verifyTicket(uint _eventID, uint _ticketID, string _uud) public view returns(uint) {
        bytes32 key = keccak256(abi.encodePacked(_eventID,_ticketID,"Event Ticket Owner"));
        address _owner = mem.getAddress(key);
        key = keccak256(abi.encodePacked(_owner,"Secondary","Metadata"));
        string memory ownerData = mem.getString(key);
        bytes32 b1 = keccak256(abi.encodePacked(ownerData));
        bytes32 b2 = keccak256(abi.encodePacked(_uud));
        return b1 == b2 ? 1 : 0;
    }
}