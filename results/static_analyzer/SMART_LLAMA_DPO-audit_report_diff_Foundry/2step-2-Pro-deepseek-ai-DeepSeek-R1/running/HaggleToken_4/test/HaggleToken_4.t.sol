// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HaggleToken.sol";

contract HaggleXToken_MintingPrivilegeTest is Test {
    HaggleXToken token;
    address owner = address(0x1);
    address maliciousUser = address(0x666);
    address recipientA = address(0xA);
    address recipientB = address(0xB);
    address[] targets = new address[](2);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new HaggleXToken();
        targets[0] = recipientA;
        targets[1] = recipientB;
        vm.stopPrank();
    }

    function test_unauthorizedMint() public {
        console.log("--- BEFORE Unauthorized Mint ---");
        uint256 beforeBalanceA = token.balanceOf(recipientA);
        uint256 beforeBalanceB = token.balanceOf(recipientB);
        uint256 beforeSupply = token.totalSupply();
        console.log("recipientA balance:", beforeBalanceA);
        console.log("recipientB balance:", beforeBalanceB);
        console.log("Total supply:", beforeSupply);

        console.log("--- Trigger: Malicious Mint Attempt ---");
        // Malicious user should not be able to mint tokens
        vm.startPrank(maliciousUser);
        vm.expectRevert("HaggleX Token: Only minter and owner can mint tokens!");
        token.mint(recipientA, 100 ether);
        
        vm.expectRevert("HaggleX Token: Only Owner can perform this task");
        token.mintToMultipleAddresses(targets, 100 ether);
        vm.stopPrank();
        console.log("Both malicious mint attempts reverted as expected");

        console.log("--- AFTER Unauthorized Mint ---");
        uint256 afterBalanceA = token.balanceOf(recipientA);
        uint256 afterBalanceB = token.balanceOf(recipientB);
        uint256 afterSupply = token.totalSupply();
        console.log("recipientA balance:", afterBalanceA);
        console.log("recipientB balance:", afterBalanceB);
        console.log("Total supply:", afterSupply);

        console.log("--- State Change Comparison ---");
        bool balanceUnchanged = (beforeBalanceA == afterBalanceA) && 
                                (beforeBalanceB == afterBalanceB);
        bool supplyUnchanged = (beforeSupply == afterSupply);
        
        require(balanceUnchanged && supplyUnchanged, "State changed after unauthorized mint");
        
        if (balanceUnchanged && supplyUnchanged) {
            console.log("Verification: Token state remains unchanged");
            console.log("Vulnerability not Exist: Unauthorized mint attempts were successfully reverted and state preserved");
        } else {
            console.log("Vulnerability Exists: Unauthorized mint operations modified token state");
        }
    }

    function test_ownerPrivilegeEscalation() public {
        // Owner can mint any amount to any address
        uint256 beforeSupply = token.totalSupply();
        vm.startPrank(owner);
        token.mint(recipientA, 100 ether);
        token.mintToMultipleAddresses(targets, 200 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(recipientA), 300 ether);
        assertEq(token.balanceOf(recipientB), 200 ether);
        assertEq(token.totalSupply(), beforeSupply + 500 ether);
    }
}