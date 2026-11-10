// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract CHITAVERSEUniquenessTest is Test {
    CHITAVERSE token;
    address owner = address(0x1);
    address attacker = address(0xBAD);
    address recipient = address(0xCAFE);
    address constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Mock router and factory responses
        address fakeFactory = address(0xF00D);
        bytes4 factorySelector = bytes4(keccak256("factory()"));
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        
        vm.mockCall(
            REAL_ROUTER,
            abi.encodePacked(factorySelector),
            abi.encode(fakeFactory)
        );
        
        vm.mockCall(
            fakeFactory,
            abi.encodePacked(createPairSelector), 
            abi.encode(address(0x1))
        );

        // Deploy token in owner context
        vm.startPrank(owner);
        token = new CHITAVERSE();
        vm.stopPrank();

        // Configure token settings
        vm.startPrank(owner);
        token.setSwapBackSettings(false, 0); // Disable swap back
        token.setTxLimit(type(uint256).max);
        token.setMaxWallet(type(uint256).max);
        token.setIsFeeExempt(attacker, true);
        token.setIsFeeExempt(recipient, true);
        token.setIsFeeExempt(owner, true);
        vm.stopPrank();

        // Transfer reasonable initial tokens to attacker (10% of supply)
        uint256 total = token.totalSupply();
        vm.prank(owner);
        token.transfer(attacker, total / 10);
    }

    function testMultipleTransfersInSameBlock() public {
        uint256 amount = 1000; // Use a reasonable amount
        
        // Log initial state for differential validation
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 initialAttackBalance = token.balanceOf(attacker);
        uint256 initialRecipientBalance = token.balanceOf(recipient);
        console.log("Attacker balance:", initialAttackBalance);
        console.log("Recipient balance:", initialRecipientBalance);
        console.log("Expected after-transfer change: %d tokens each way", amount * 2);
        
        console.log("\n--- Trigger Multiple Transfers ---");
        vm.startPrank(attacker);
        // First transfer
        token.transfer(recipient, amount);
        // Second transfer in same block
        token.transfer(recipient, amount);
        vm.stopPrank();
        console.log("Executed two transfers in same block from %s to %s", attacker, recipient);
        
        // Log after state for differential validation
        console.log("\n--- AFTER-Trigger Balances ---");
        uint256 finalAttackBalance = token.balanceOf(attacker);
        uint256 finalRecipientBalance = token.balanceOf(recipient);
        console.log("Attacker balance:", finalAttackBalance);
        console.log("Recipient balance:", finalRecipientBalance);
        
        // Calculate actual balance changes
        uint256 actualAttackChange = initialAttackBalance - finalAttackBalance;
        uint256 actualRecipientChange = finalRecipientBalance - initialRecipientBalance;
        
        // Compare actual vs expected changes
        bool attackChangeCorrect = actualAttackChange == amount * 2;
        bool recipientChangeCorrect = actualRecipientChange == amount * 2;
        bool bothTransfersSuccessful = attackChangeCorrect && recipientChangeCorrect;
        
        console.log("\n--- Differential Validation Result ---");
        console.log("Expected attack balance change: %d", amount * 2);
        console.log("Actual attack balance change  : %d | Status: %s", 
            actualAttackChange, 
            attackChangeCorrect ? "MATCH" : "MISMATCH");
        
        console.log("Expected recipient balance change: %d", amount * 2);
        console.log("Actual recipient balance change  : %d | Status: %s", 
            actualRecipientChange, 
            recipientChangeCorrect ? "MATCH" : "MISMATCH");
        
        // Final verdict
        if(bothTransfersSuccessful) {
            console.log("\nVulnerability Exists: Both transfers succeeded in same block and balances updated correctly");
        } else {
            console.log("\nVulnerability not Exist: The two transfers in same block either reverted or balances didn't update as expected");
        }
    }
}