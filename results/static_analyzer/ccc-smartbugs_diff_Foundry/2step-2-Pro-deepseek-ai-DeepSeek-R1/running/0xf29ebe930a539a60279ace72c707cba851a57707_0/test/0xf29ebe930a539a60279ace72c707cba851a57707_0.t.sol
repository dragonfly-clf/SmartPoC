// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/0xf29ebe930a539a60279ace72c707cba851a57707.sol";

// Helper contract that reverts when receiving ETH
contract FaultyOwner {
    receive() external payable {
        revert();
    }
}

contract BTest is Test {
    B public bContract;
    address public faultyOwnerAddr;
    address public user = makeAddr("user");
    // Target address for balance check
    address constant TARGET_ADDR = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
    
    function setUp() public {
        // Create faulty owner contract
        faultyOwnerAddr = address(new FaultyOwner());
        
        // Deploy contract B as faulty owner
        vm.prank(faultyOwnerAddr);
        bContract = new B();
        
        // Pre-fund contract B with 0.5 ether to enable withdrawal
        vm.deal(address(bContract), 0.5 ether);
        
        // Fund test user
        vm.deal(user, 1 ether);
    }

    function test_GoFunctionTriggersDoS() public {
        // 1. Capture state before function call
        console.log("--- BEFORE Trigger Function go() ---");
        uint256 totalDepositsBefore = bContract.totalDeposits();
        console.log("totalDeposits: %s", totalDepositsBefore);
        
        uint256 userDepositBefore = bContract.userDeposits(user);
        console.log("user %s deposit: %s", user, userDepositBefore);
        
        uint256 totalWithdrawalsBefore = bContract.totalWithdrawals();
        console.log("totalWithdrawals: %s", totalWithdrawalsBefore);
        
        uint256 contractBalanceBefore = address(bContract).balance;
        console.log("Contract balance: %s", contractBalanceBefore);
        
        uint256 faultyOwnerBalanceBefore = faultyOwnerAddr.balance;
        console.log("Faulty owner balance: %s", faultyOwnerBalanceBefore);
        
        uint256 userBalanceBefore = user.balance;
        console.log("User balance: %s", userBalanceBefore);
        
        uint256 targetBalanceBefore = TARGET_ADDR.balance;
        console.log("Target address balance: %s", targetBalanceBefore);

        // 2. Execute go function call (expect revert)
        console.log("--- Trigger Function go() ---");
        vm.expectRevert();
        vm.prank(user);
        bContract.go{value: 1 ether}();

        // 3. Capture state after function call
        console.log("--- AFTER Trigger Function go() ---");
        uint256 totalDepositsAfter = bContract.totalDeposits();
        console.log("totalDeposits: %s", totalDepositsAfter);
        
        uint256 userDepositAfter = bContract.userDeposits(user);
        console.log("user %s deposit: %s", user, userDepositAfter);
        
        uint256 totalWithdrawalsAfter = bContract.totalWithdrawals();
        console.log("totalWithdrawals: %s", totalWithdrawalsAfter);
        
        uint256 contractBalanceAfter = address(bContract).balance;
        console.log("Contract balance: %s", contractBalanceAfter);
        
        uint256 faultyOwnerBalanceAfter = faultyOwnerAddr.balance;
        console.log("Faulty owner balance: %s", faultyOwnerBalanceAfter);
        
        uint256 userBalanceAfter = user.balance;
        console.log("User balance: %s", userBalanceAfter);
        
        uint256 targetBalanceAfter = TARGET_ADDR.balance;
        console.log("Target address balance: %s", targetBalanceAfter);

        // 4. Compare states
        bool stateUnchanged = 
            (totalDepositsBefore == totalDepositsAfter) &&
            (userDepositBefore == userDepositAfter) &&
            (totalWithdrawalsBefore == totalWithdrawalsAfter) &&
            (contractBalanceBefore == contractBalanceAfter) &&
            (faultyOwnerBalanceBefore == faultyOwnerBalanceAfter) &&
            (userBalanceBefore == userBalanceAfter) &&
            (targetBalanceBefore == targetBalanceAfter);
        
        // 5. Final verdict
        if (stateUnchanged) {
            console.log("Vulnerability Exists: All state variables unchanged after reverted call.");
        } else {
            console.log("Vulnerability not Exist: State variables changed after reverted call.");
        }
    }
}