// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x5aa88d2901c68fda244f1d0584400368d2c8e739.sol";

contract MultiplicatorX3Test is Test {
    MultiplicatorX3 public multiplicator;
    address owner = address(0x1);
    
    // Target contract that will fail when receiving ETH
    ContractFailOnReceive public failContract;

    function setUp() public {
        vm.startPrank(owner);
        multiplicator = new MultiplicatorX3();
        failContract = new ContractFailOnReceive();
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        // Fund the contract with some ETH
        vm.deal(address(multiplicator), 1 ether);

        console2.log("--- BEFORE-Trigger Call ---");
        uint256 multiBalanceBefore = address(multiplicator).balance;
        uint256 failBalanceBefore = address(failContract).balance;
        console2.log("MultiplicatorX3 balance (before):", multiBalanceBefore);
        console2.log("FailContract balance (before):", failBalanceBefore);

        console2.log("--- Trigger (Call Command) ---");
        // Verify the vulnerable Command function doesn't check call success
        vm.prank(owner);
        multiplicator.Command(
            address(failContract),
            abi.encodeWithSignature("nonExistingFunction()")
        );

        console2.log("--- AFTER-Trigger Call ---");
        uint256 multiBalanceAfter = address(multiplicator).balance;
        uint256 failBalanceAfter = address(failContract).balance;
        console2.log("MultiplicatorX3 balance (after):", multiBalanceAfter);
        console2.log("FailContract balance (after):", failBalanceAfter);

        // Compare balances before and after
        bool balancesUnchanged = (multiBalanceBefore == multiBalanceAfter) && 
                                 (failBalanceBefore == failBalanceAfter);
        
        console2.log("\n[DIFFERENTIAL RESULT]");
        console2.log("Balances unchanged:", balancesUnchanged ? "true" : "false");
        
        // Final vulnerability verdict
        if (balancesUnchanged) {
            console2.log("Vulnerability Exists: Unchecked low-level call allows transfer failure without state rollback");
        } else {
            console2.log("Vulnerability not Exist: Balances changed unexpectedly during failed call");
        }

        // Original assertions for compatibility
        assertEq(address(failContract).balance, 0);
        assertEq(address(multiplicator).balance, 1 ether);
    }
}

// Helper contract that fails when receiving ETH
contract ContractFailOnReceive {
    fallback() external payable {
        revert("This contract rejects ETH");
    }
}