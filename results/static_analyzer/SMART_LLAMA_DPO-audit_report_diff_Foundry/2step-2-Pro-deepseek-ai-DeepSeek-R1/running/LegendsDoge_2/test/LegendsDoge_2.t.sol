// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LegendsDoge.sol";

contract LegendsDogeTest is Test {
    LegendsDoge token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new LegendsDoge(
            "LegendsDoge", 
            "LDOGE", 
            9, 
            1_000_000_000, 
            0, 
            0, 
            0, 
            address(0), 
            owner
        );
        
        // Configure token to allow transfers without fees or limits
        token.updateFee(0, 0, 0);
        token.setMaxTxPercent(100);
        token.setMaxWalletPercent(100);
        
        // Send tokens to test user
        uint256 amount = 100 * (10 ** token.decimals());
        token.transfer(user1, amount * 2);
        vm.stopPrank();
    }

    /// @dev Test that duplicate transfers are possible
    function testIdUniquenessViolationTransfer() public {
        uint256 transferAmount = 100 * (10 ** token.decimals());
        console.log("--- BEFORE FIRST TRANSFER ---");
        uint256 initialUser1 = token.balanceOf(user1);
        uint256 initialUser2 = token.balanceOf(user2);
        console.log("user1 initial balance:", initialUser1);
        console.log("user2 initial balance:", initialUser2);

        console.log("--- FIRST TRANSFER TRIGGERED ---");
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        console.log("--- AFTER FIRST TRANSFER ---");
        uint256 afterFirstUser1 = token.balanceOf(user1);
        uint256 afterFirstUser2 = token.balanceOf(user2);
        console.log("user1 balance:", afterFirstUser1);
        console.log("user2 balance:", afterFirstUser2);
        uint256 firstTransferAmount = afterFirstUser2 - initialUser2;
        console.log("Actual transfer amount:", firstTransferAmount);
        
        console.log("--- BEFORE SECOND TRANSFER ---");
        console.log("user1 balance:", afterFirstUser1);
        console.log("user2 balance:", afterFirstUser2);
        
        console.log("--- SECOND TRANSFER TRIGGERED ---");
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        console.log("--- AFTER SECOND TRANSFER ---");
        uint256 finalUser1 = token.balanceOf(user1);
        uint256 finalUser2 = token.balanceOf(user2);
        console.log("user1 final balance:", finalUser1);
        console.log("user2 final balance:", finalUser2);
        uint256 secondTransferAmount = finalUser2 - afterFirstUser2;
        console.log("Actual transfer amount:", secondTransferAmount);
        
        // Validation
        uint256 expectedFinalBalance = afterFirstUser2 + transferAmount;
        bool duplicatedSucceeded = (secondTransferAmount == transferAmount) &&
                                  (finalUser2 == expectedFinalBalance);
        
        if (duplicatedSucceeded) {
            console.log("Vulnerability Exists: Duplicate transfers allowed without uniqueness check");
        } else {
            console.log("Vulnerability not Exist: Transfer amounts mismatch");
        }
        
        assertEq(finalUser2, initialUser2 + (transferAmount * 2), 
            "Duplicate transfers should increase balance multiple times");
    }

    /// @dev Test that duplicate transferFrom operations are possible
    function testIdUniquenessViolationTransferFrom() public {
        uint256 transferAmount = 100 * (10 ** token.decimals());
        console.log("--- BEFORE FIRST TRANSFERFROM ---");
        uint256 initialUser1 = token.balanceOf(user1);
        uint256 initialUser2 = token.balanceOf(user2);
        console.log("user1 initial balance:", initialUser1);
        console.log("user2 initial balance:", initialUser2);

        // Approve user1 to spend tokens
        vm.startPrank(user1);
        token.approve(address(this), transferAmount * 2);
        vm.stopPrank();

        console.log("--- FIRST TRANSFERFROM TRIGGERED ---");
        token.transferFrom(user1, user2, transferAmount);
        
        console.log("--- AFTER FIRST TRANSFERFROM ---");
        uint256 afterFirstUser1 = token.balanceOf(user1);
        uint256 afterFirstUser2 = token.balanceOf(user2);
        console.log("user1 balance:", afterFirstUser1);
        console.log("user2 balance:", afterFirstUser2);
        uint256 firstTransferAmount = afterFirstUser2 - initialUser2;
        console.log("Actual transfer amount:", firstTransferAmount);
        
        console.log("--- BEFORE SECOND TRANSFERFROM ---");
        console.log("user1 balance:", afterFirstUser1);
        console.log("user2 balance:", afterFirstUser2);
        
        console.log("--- SECOND TRANSFERFROM TRIGGERED ---");
        token.transferFrom(user1, user2, transferAmount);
        
        console.log("--- AFTER SECOND TRANSFERFROM ---");
        uint256 finalUser1 = token.balanceOf(user1);
        uint256 finalUser2 = token.balanceOf(user2);
        console.log("user1 final balance:", finalUser1);
        console.log("user2 final balance:", finalUser2);
        uint256 secondTransferAmount = finalUser2 - afterFirstUser2;
        console.log("Actual transfer amount:", secondTransferAmount);
        
        // Validation
        uint256 expectedFinalBalance = afterFirstUser2 + transferAmount;
        bool duplicatedSucceeded = (secondTransferAmount == transferAmount) &&
                                  (finalUser2 == expectedFinalBalance);
        
        if (duplicatedSucceeded) {
            console.log("Vulnerability Exists: Duplicate transferFrom allowed without uniqueness check");
        } else {
            console.log("Vulnerability not Exist: TransferFrom amounts mismatch");
        }
        
        assertEq(finalUser2, initialUser2 + (transferAmount * 2),
            "Duplicate transferFrom should increase balance multiple times");
    }
}