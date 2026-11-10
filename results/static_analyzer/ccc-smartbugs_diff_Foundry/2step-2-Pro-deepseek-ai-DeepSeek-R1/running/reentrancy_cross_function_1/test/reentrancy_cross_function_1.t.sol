// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract OverflowTest is Test {
    Reentrancy_cross_function public targetContract;
    address user1 = address(0x1);
    address user2 = address(0x2);
    bool public transferSucceeded;
    bool public vulnerabilityExists;

    function setUp() public {
        targetContract = new Reentrancy_cross_function();
        
        // Fund users with ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_overflowVulnerability() public {
        // Setup initial balances: user1 deposits 1 ether
        vm.startPrank(user1);
        targetContract.deposit{value: 1 ether}();
        vm.stopPrank();
        
        // Compute storage slot for userBalances[user2] (slot 0 for mapping)
        bytes32 user2BalSlot = keccak256(abi.encode(user2, uint256(0)));
        bytes32 maxUint = bytes32(type(uint256).max);
        
        // Set user2's balance to max uint256
        vm.store(address(targetContract), user2BalSlot, maxUint);
        
        // Validate pre-condition
        assertEq(targetContract.getBalance(user2), type(uint256).max);
        
        // BEFORE: Get pre-transfer balances
        console2.log("--- BEFORE-Trigger Transfer Balances ---");
        uint256 preUser1Balance = targetContract.getBalance(user1);
        uint256 preUser2Balance = targetContract.getBalance(user2);
        console2.log("User1 balance (pre):", preUser1Balance);
        console2.log("User2 balance (pre):", preUser2Balance);
        
        console2.log("--- Trigger Transfer (1 wei from user1 to user2) ---");
        // Attempt transfer with overflow protection
        vm.startPrank(user1);
        (transferSucceeded, ) = address(targetContract).call(
            abi.encodeWithSignature("transfer(address,uint256)", user2, 1)
        );
        vm.stopPrank();
        console2.log("Transfer status:", transferSucceeded ? "succeeded" : "reverted");
        
        console2.log("--- AFTER-Trigger Transfer Balances ---");
        uint256 postUser1Balance = targetContract.getBalance(user1);
        uint256 postUser2Balance = targetContract.getBalance(user2);
        console2.log("User1 balance (post):", postUser1Balance);
        console2.log("User2 balance (post):", postUser2Balance);
        
        // Check if overflow occurred
        vulnerabilityExists = transferSucceeded && 
                             (postUser2Balance == 0) && 
                             (postUser1Balance == preUser1Balance - 1);

        // Final verdict based on detection
        if(vulnerabilityExists) {
            console2.log("Vulnerability Exists: Overflow occurred causing user2 balance to wrap to 0");
        } else {
            console2.log("Vulnerability not Exist: Overflow either reverted or didn't cause expected balance changes");
        }
    }
}