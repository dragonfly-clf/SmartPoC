// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract FailureContract {
    receive() external payable {
        revert();
    }
}

contract UncheckedTransferTest is Test {
    Reentrancy_cross_function rc;
    address user = makeAddr("user");
    FailureContract failContract;
    
    function setUp() public {
        // Deploy vulnerable contract and failing contract
        rc = new Reentrancy_cross_function();
        failContract = new FailureContract();
        
        // Fund user and deposit to vulnerable contract
        vm.deal(user, 10 ether);
        vm.prank(user);
        rc.deposit{value: 10 ether}();
    }

    function testUncheckedTransferFailure() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialUserBalance = rc.getBalance(user);
        uint256 initialFailContractBalance = address(failContract).balance;
        console2.log("User internal balance (before): %s", initialUserBalance);
        console2.log("Fail contract ether balance (before): %s", initialFailContractBalance);

        console2.log("--- Trigger Transfer ---");
        vm.prank(user);
        rc.transfer(address(failContract), 1 ether);

        console2.log("--- AFTER-Trigger State ---");
        uint256 finalUserBalance = rc.getBalance(user);
        uint256 finalFailContractBalance = address(failContract).balance;
        console2.log("User internal balance (after): %s", finalUserBalance);
        console2.log("Fail contract ether balance (after): %s", finalFailContractBalance);

        bool balanceDecreased = initialUserBalance - finalUserBalance == 1 ether;
        bool receiverUnchanged = finalFailContractBalance == initialFailContractBalance;
        bool vulnerabilityExists = balanceDecreased && receiverUnchanged;
        
        console2.log("Consistency check:");
        console2.log("- User balance decreased: %s", balanceDecreased);
        console2.log("- Receiver balance unchanged: %s", receiverUnchanged);
        console2.log("- State inconsistency: %s", vulnerabilityExists);

        // Final conditional verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Internal balance deducted but receiver did not receive ETH");
        } else {
            console2.log("Vulnerability not Exist: Contract state remains consistent after transfer");
        }
    }
}