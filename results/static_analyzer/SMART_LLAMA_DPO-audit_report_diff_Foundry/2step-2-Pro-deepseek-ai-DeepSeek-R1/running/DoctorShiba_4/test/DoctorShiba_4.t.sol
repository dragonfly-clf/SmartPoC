// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaPrivilegeTest is Test {
    DoctorShiba token;
    address owner = address(this);
    address attacker = address(0x666);
    
    function setUp() public {
        token = new DoctorShiba();
    }

    function testOwnerCanSetMaliciousNewun() public {
        // Demonstrate owner can set arbitrary address as newun
        assertTrue(owner == token.owner(), "Test contract should be owner");
        
        console.log("--- BEFORE-Trigger newun ---");
        address oldNewun = token.newun();
        console.log("Old newun address:", oldNewun);
        
        console.log("--- Trigger Transfernewun ---");
        token.transfernewun(attacker);
        
        console.log("--- AFTER-Trigger newun ---");
        address newNewun = token.newun();
        console.log("New newun address:", newNewun);

        if (newNewun == attacker) {
            console.log("Vulnerability Exists: Owner changed newun to attacker address");
        } else {
            console.log("Vulnerability not Exist: Failed to change newun to attacker");
        }
    }

    function testOwnerCanMintArbitraryTokens() public {
        address recipient = address(0x999);
        uint256 initialSupply = token.totalSupply();
        uint256 mintAmount = 1000e18;
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Recipient balance before:", recipientBalanceBefore);
        console.log("Total supply before:", totalSupplyBefore);
        
        console.log("--- Trigger Mint ---");
        token.mint(recipient, mintAmount);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Recipient balance after:", recipientBalanceAfter);
        console.log("Total supply after:", totalSupplyAfter);
        
        uint256 actualBalanceIncrease = recipientBalanceAfter - recipientBalanceBefore;
        uint256 actualSupplyIncrease = totalSupplyAfter - totalSupplyBefore;
        bool validMintResult = (actualBalanceIncrease == mintAmount) && (actualSupplyIncrease == mintAmount);
        
        if (validMintResult) {
            console.log("Vulnerability Exists: Owner can mint arbitrary tokens, leading to inflation");
        } else {
            console.log("Vulnerability not Exist: Mint did not work as expected");
        }
        
        // Original verification keeps functional
        assertEq(token.balanceOf(recipient), mintAmount, "Recipient didn't receive tokens");
        assertEq(token.totalSupply(), initialSupply + mintAmount, "Total supply not increased");
    }
}