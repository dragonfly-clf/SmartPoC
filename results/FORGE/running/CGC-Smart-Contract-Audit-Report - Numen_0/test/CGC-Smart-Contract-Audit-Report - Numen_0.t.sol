// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CarGaiaToken.sol";

contract CarGaiaTokenBlackListTest is Test {
    CarGaiaToken token;
    address constant SALE_ADDRESS = address(0x10);
    address constant ALICE = address(0x2);
    address constant BOB = address(0x3);
    address constant CHARLIE = address(0x4);
    
    uint constant INITIAL_SUPPLY = 1000000000 * 10**18;
    uint constant TRANSFER_AMOUNT = 100 * 10**18;
    
    function setUp() public {
        // Deploy token contract
        token = new CarGaiaToken(
            INITIAL_SUPPLY,
            "CarGaia",
            "CG",
            18,
            SALE_ADDRESS,
            address(0x11),
            address(0x12),
            address(0x13),
            address(0x14),
            address(0x1)  // Team address
        );
        
        // Fund Alice from SALE_ADDRESS which has unlocked tokens
        vm.prank(SALE_ADDRESS);
        token.transfer(ALICE, TRANSFER_AMOUNT);
    }

    // Test 1: Blacklisted sender cannot transfer (transfer function)
    function testBlacklistedSenderTransferReverts() public {
        // Blacklist ALICE
        token.addBlackList(ALICE);

        // Attempt transfer from ALICE
        vm.prank(ALICE);
        vm.expectRevert();
        token.transfer(BOB, TRANSFER_AMOUNT);
    }

    // Test 2: Blacklisted 'from' cannot have tokens moved (transferFrom)
    function testBlacklistedFromTransferFromReverts() public {
        // Approve BOB to spend ALICE's tokens
        vm.prank(ALICE);
        token.approve(BOB, TRANSFER_AMOUNT);

        // Blacklist ALICE
        token.addBlackList(ALICE);

        // BOB attempts transferFrom
        vm.prank(BOB);
        vm.expectRevert();
        token.transferFrom(ALICE, CHARLIE, TRANSFER_AMOUNT);
    }

    // Test 3: Transfer to blacklisted recipient succeeds (audit finding)
    function testTransferToBlacklistedRecipientSucceeds() public {
        // Blacklist CHARLIE (recipient)
        token.addBlackList(CHARLIE);

        console.log("--- BEFORE-Trigger ---");
        uint256 saleBalanceBefore = token.balanceOf(SALE_ADDRESS);
        uint256 charlieBalanceBefore = token.balanceOf(CHARLIE);
        console.log("SALE_ADDRESS balance before: ", saleBalanceBefore);
        console.log("CHARLIE balance before:     ", charlieBalanceBefore);

        console.log("--- Trigger Transfer ---");
        // Transfer from SALE_ADDRESS to CHARLIE
        vm.prank(SALE_ADDRESS);
        token.transfer(CHARLIE, TRANSFER_AMOUNT);

        console.log("--- AFTER-Trigger ---");
        uint256 saleBalanceAfter = token.balanceOf(SALE_ADDRESS);
        uint256 charlieBalanceAfter = token.balanceOf(CHARLIE);
        console.log("SALE_ADDRESS balance after:  ", saleBalanceAfter);
        console.log("CHARLIE balance after:      ", charlieBalanceAfter);

        // Calculate balance differences
        uint256 saleDiff = saleBalanceBefore - saleBalanceAfter;
        uint256 charlieDiff = charlieBalanceAfter - charlieBalanceBefore;

        // Verify CHARLIE received tokens (existing check)
        assertEq(token.balanceOf(CHARLIE), TRANSFER_AMOUNT);

        // Differential validity check
        if (saleDiff == TRANSFER_AMOUNT && charlieDiff == TRANSFER_AMOUNT) {
            console.log("Vulnerability Exists: Transfer succeeded to blacklisted recipient");
        } else {
            console.log("Vulnerability not Exist: Balances didn't change by transfer amount");
        }
    }
}