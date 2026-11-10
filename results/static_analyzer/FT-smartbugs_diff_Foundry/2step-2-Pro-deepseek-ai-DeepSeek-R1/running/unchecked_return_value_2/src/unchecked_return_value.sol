pragma solidity ^0.8.26;

contract ReturnValue {
    mapping(address => uint256) public callCounts;
    mapping(address => uint256) public successfulCalls;
    uint256 public totalCalls;
    uint256 public totalSuccessfulCalls;
    
    event CallAttempt(address indexed caller, address indexed callee, bool success);
    event CallCompleted(address indexed callee, uint256 callCount);

    function callchecked(address callee) public {
        (bool success, ) = payable(callee).call("");
        require(success);
        
        callCounts[callee]++;
        successfulCalls[callee]++;
        totalCalls++;
        totalSuccessfulCalls++;
        
        emit CallAttempt(msg.sender, callee, true);
        emit CallCompleted(callee, callCounts[callee]);
    }

    function callnotchecked(address callee) public {
        payable(callee).call("");
        
        callCounts[callee]++;
        totalCalls++;
        
        emit CallAttempt(msg.sender, callee, false);
        emit CallCompleted(callee, callCounts[callee]);
    }

    function getCallStats(address callee) public view returns (uint256 calls, uint256 successful) {
        return (callCounts[callee], successfulCalls[callee]);
    }
}