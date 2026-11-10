// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette public roulette;
    address public owner = makeAddr("owner");
    address public player = makeAddr("player");
    uint256 public constant BET_VALUE = 1 ether;
    uint256 public constant MINING_WINDOW = 900 seconds; // Max miner timestamp manipulation

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(player, 10 ether);
        vm.startPrank(owner);
        roulette = new CryptoRoulette();
        payable(address(roulette)).transfer(3 ether); // Fund contract
        vm.stopPrank();
    }

    function test_prematureDestruction() public {
        // Play a game to set lastPlayed
        vm.prank(player);
        roulette.play{value: BET_VALUE}(1);
        uint256 contractBalance = address(roulette).balance; // Capture current balance

        // Simulate timestamp manipulation by a miner
        uint256 normalPassedTime = 12 hours - MINING_WINDOW; // Real elapsed time
        uint256 manipulatedBlockTime = block.timestamp + 1 days - MINING_WINDOW;

        // [DIFF START] - Premature kill differential validation
        console.log("--- BEFORE Premature Kill ---");
        uint256 contractBalanceBefore = address(roulette).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console.log("Contract Balance  :", contractBalanceBefore);
        console.log("Owner Balance     :", ownerBalanceBefore);

        console.log("--- TRIGGER Premature Kill ---");
        vm.warp(manipulatedBlockTime);
        uint256 existingOwnerBalBefore = owner.balance; // Keep for existing assertion
        vm.prank(owner);
        roulette.kill();

        console.log("--- AFTER Premature Kill ---");
        uint256 contractBalanceAfter = address(roulette).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console.log("Contract Balance  :", contractBalanceAfter);
        console.log("Owner Balance     :", ownerBalanceAfter);

        bool prematureKillSucceeded = (contractBalanceAfter != contractBalanceBefore) || 
                                     (ownerBalanceAfter != ownerBalanceBefore);
        // [DIFF END]

        // Verify contract not destroyed prematurely
        assertGt(
            address(roulette).balance, 
            0,
            "Contract should not be destroyed before timelock"
        );
        assertEq(
            owner.balance,
            existingOwnerBalBefore,
            "No funds should be transferred before timelock"
        );

        // 2. Verify proper destruction after real timelock
        vm.warp(block.timestamp + normalPassedTime + MINING_WINDOW); // Real 1 day passed
        
        // [DIFF START] - Normal kill differential validation (optional)
        console.log("--- BEFORE Normal Kill ---");
        uint256 normalContractBalBefore = address(roulette).balance;
        uint256 normalOwnerBalBefore = owner.balance;

        console.log("--- TRIGGER Normal Kill ---");
        vm.prank(owner);
        roulette.kill();
        
        console.log("--- AFTER Normal Kill ---");
        console.log("Contract Balance  :", address(roulette).balance);
        console.log("Owner Balance     :", owner.balance);
        // [DIFF END]

        // Confirm contract destroyed with funds transferred
        assertEq(
            address(roulette).balance, 
            0, 
            "Contract should selfdestruct after timelock"
        );
        assertEq(
            owner.balance,
            normalOwnerBalBefore + normalContractBalBefore,
            "Owner should receive contract funds"
        );

        // Final vulnerability verdict
        if (prematureKillSucceeded) {
            console.log("Vulnerability Exists: Owner drained funds with miner timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Timelock prevents premature destruction");
        }
    }
}