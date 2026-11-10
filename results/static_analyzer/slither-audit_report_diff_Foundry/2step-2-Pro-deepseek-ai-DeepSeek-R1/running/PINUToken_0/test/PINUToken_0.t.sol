// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

contract MockPinkAntiBot {
    function setTokenOwner(address) public pure {}
}

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    constructor() {
        balanceOf[address(this)] = 1 ether;
    }
    
    function setBalance(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }
    
    function transfer(address, uint256) public pure returns (bool) {
        return false; // Always fails
    }
}

contract PINUTokenWithdrawTokenTest is Test {
    PINUToken token;
    MaliciousToken maliciousToken;
    address owner;
    address constant REWARD_TOKEN = address(0x1234);

    function setUp() public {
        owner = address(this);
        address[] memory emptyArray;

        MockPinkAntiBot mockPinkAntiBot = new MockPinkAntiBot();
        token = new PINUToken(
            address(mockPinkAntiBot),
            emptyArray,
            REWARD_TOKEN
        );

        maliciousToken = new MaliciousToken();
        // Set balances directly since transfer fails
        maliciousToken.setBalance(address(token), 1 ether); 
        maliciousToken.setBalance(address(this), 0);
    }

    function testWithdrawTokenFailsSilently() public {
        console.log("--- BEFORE State ---");
        uint256 initialContractBalance = maliciousToken.balanceOf(address(token));
        uint256 initialOwnerBalance = maliciousToken.balanceOf(owner);
        console.log("Contract maliciousToken balance:", initialContractBalance);
        console.log("Owner maliciousToken balance:", initialOwnerBalance);

        console.log("--- Trigger: withdrawToken ---");
        token.withdrawToken(address(maliciousToken));

        console.log("--- AFTER State ---");
        uint256 afterContractBalance = maliciousToken.balanceOf(address(token));
        uint256 afterOwnerBalance = maliciousToken.balanceOf(owner);
        console.log("Contract maliciousToken balance:", afterContractBalance);
        console.log("Owner maliciousToken balance:", afterOwnerBalance);

        // Compare state changes
        if (afterContractBalance == initialContractBalance && 
            afterOwnerBalance == initialOwnerBalance) {
            console.log("Vulnerability Exists: withdrawToken fails silently without reverting");
        } else {
            console.log("Vulnerability not Exist: withdrawToken function transferred tokens successfully");
        }
    }
}