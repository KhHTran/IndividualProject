pragma solidity ^0.4.24;
import "../interfaces/MemoryInterface.sol";
import "./TokenMemory.sol";
contract TokenManagerLib {
	function secureDeposit(address _depositor, uint _deposit, MemoryInterface _memory) external {
		uint requiredDeposit = TokenMemory.getRequiredDeposit(_depositor,_memory);
		uint depositBalance = TokenMemory.getDepositBalance(_depositor,_memory);
		require(requiredDeposit + _deposit <= depositBalance, "Not enough deposit credit");
		TokenMemory.setRequiredDeposit(_depositor,_deposit + requiredDeposit, _memory);
	}
}