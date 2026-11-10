// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract DemoTest is Test {
    demo public tokenBatchTransfer;
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    // Mock token that will fail transfers
    MockToken public failingToken;

    function setUp() public {
        vm.startPrank(owner);
        tokenBatchTransfer = new demo();
        failingToken = new MockToken();
        tokenBatchTransfer.approveToken(address(failingToken));
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        // Mint tokens to owner
        failingToken.mint(owner, 100 ether);

        // Prepare transfer parameters
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;

        uint[] memory amounts = new uint[](2);
        amounts[0] = 50 ether;
        amounts[1] = 50 ether;

        // First transfer should work normally
        vm.prank(owner);
        tokenBatchTransfer.transfer(owner, address(failingToken), recipients, amounts);

        // Check balances were updated correctly
        assertEq(tokenBatchTransfer.getUserBalance(user1), 50 ether);
        assertEq(tokenBatchTransfer.getUserBalance(user2), 50 ether);

        // Now make the token fail transfers
        failingToken.setShouldFail(true);

        // --- BEFORE-Trigger Transfer ---
        console.log("--- BEFORE-Trigger Transfer ---");
        uint totalTransfersBefore = tokenBatchTransfer.totalTransfers();
        uint user1BatchBefore = tokenBatchTransfer.getUserBalance(user1);
        uint user2BatchBefore = tokenBatchTransfer.getUserBalance(user2);
        uint ownerTokenBefore = failingToken.balanceOf(owner);
        uint user1TokenBefore = failingToken.balanceOf(user1);
        uint user2TokenBefore = failingToken.balanceOf(user2);

        console.log("Batch contract state BEFORE:");
        console.log("Total transfers:", totalTransfersBefore);
        console.log("User1 batch balance:", user1BatchBefore);
        console.log("User2 batch balance:", user2BatchBefore);
        
        console.log("Token balances BEFORE:");
        console.log("Token balance owner:", ownerTokenBefore);
        console.log("Token balance user1:", user1TokenBefore);
        console.log("Token balance user2:", user2TokenBefore);

        // --- TRIGGER: Failing Transfer ---
        console.log("--- TRIGGER: Execute failing transfer ---");
        vm.prank(owner);
        tokenBatchTransfer.transfer(owner, address(failingToken), recipients, amounts);
        
        // --- AFTER-Trigger Transfer ---
        console.log("--- AFTER-Trigger Transfer ---");
        uint totalTransfersAfter = tokenBatchTransfer.totalTransfers();
        uint user1BatchAfter = tokenBatchTransfer.getUserBalance(user1);
        uint user2BatchAfter = tokenBatchTransfer.getUserBalance(user2);
        uint ownerTokenAfter = failingToken.balanceOf(owner);
        uint user1TokenAfter = failingToken.balanceOf(user1);
        uint user2TokenAfter = failingToken.balanceOf(user2);

        console.log("Batch contract state AFTER:");
        console.log("Total transfers:", totalTransfersAfter);
        console.log("User1 batch balance:", user1BatchAfter);
        console.log("User2 batch balance:", user2BatchAfter);
        
        console.log("Token balances AFTER:");
        console.log("Token balance owner:", ownerTokenAfter);
        console.log("Token balance user1:", user1TokenAfter);
        console.log("Token balance user2:", user2TokenAfter);

        // --- Verdict: Check vulnerability conditions ---
        bool batchStateChanged = (user1BatchAfter != user1BatchBefore) || 
                                (user2BatchAfter != user2BatchBefore) ||
                                (totalTransfersAfter != totalTransfersBefore);
        bool tokenBalanceChanged = (ownerTokenAfter != ownerTokenBefore) || 
                                  (user1TokenAfter != user1TokenBefore) || 
                                  (user2TokenAfter != user2TokenBefore);
        bool vulnerabilityExists = batchStateChanged && !tokenBalanceChanged;

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Batch contract state changed without token transfer actually occurring");
        } else {
            console.log("Vulnerability not Exist: State remains consistent after failed transfer");
        }
    }
}

contract MockToken {
    bool public shouldFail;
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }

    function transferFrom(address /*from*/, address /*to*/, uint256 /*amount*/) public returns (bool) {
        return !shouldFail;
    }
}