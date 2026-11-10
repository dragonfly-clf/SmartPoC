// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract PieTest is Test {
    Pie pie;
    address owner = address(0x1);
    address attacker = address(0x2);
    address nonPayableContract = address(new NonPayable());

    // Event definition to match the Pie contract
    event Deposit(address indexed adr, uint256 value);

    function setUp() public {
        vm.startPrank(owner);
        pie = new Pie();
        vm.deal(owner, 10 ether);
        vm.deal(address(pie), 10 ether);
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger LowLevelCall ---");
        uint256 targetBalanceBefore = address(nonPayableContract).balance;
        uint256 pieBalanceBefore = address(pie).balance;
        uint256 totalDepositsBefore = pie.totalDeposits();
        console.log("Target contract balance: ", targetBalanceBefore);
        console.log("Pie contract balance: ", pieBalanceBefore);
        console.log("Pie totalDeposits: ", totalDepositsBefore);

        // Trigger vulnerability demonstration
        console.log("--- Trigger Command (with value 1 ether) ---");
        bytes memory data = abi.encodeWithSignature("nonExistingFunction()");
        
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit Deposit(nonPayableContract, 1 ether);
        pie.Command{value: 1 ether}(nonPayableContract, data);
        vm.stopPrank();

        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger LowLevelCall ---");
        uint256 targetBalanceAfter = address(nonPayableContract).balance;
        uint256 pieBalanceAfter = address(pie).balance;
        uint256 totalDepositsAfter = pie.totalDeposits();
        console.log("Target contract balance: ", targetBalanceAfter);
        console.log("Pie contract balance: ", pieBalanceAfter);
        console.log("Pie totalDeposits: ", totalDepositsAfter);

        // Verification checks
        assertEq(targetBalanceAfter, 0, "ETH not transferred to non-payable contract");
        uint256 expectedPieBalance = pieBalanceBefore + 1 ether;
        assertEq(pieBalanceAfter, expectedPieBalance, "Pie contract should retain ETH after failed transfer");
        
        // Vulnerability verification - state inconsistency detection
        bool stateUpdated = totalDepositsAfter != totalDepositsBefore;
        console.log("Vulnerability state change: ", stateUpdated ? "YES" : "NO");

        // Final verdict based on state change
        if (stateUpdated) {
            console.log("Vulnerability Exists: totalDeposits updated incorrectly despite failed external call");
        } else {
            console.log("Vulnerability not Exist: State remains consistent after failed call");
        }
    }
}

contract NonPayable {
    // This contract doesn't have payable fallback or receive functions
    function nonExistingFunction() external pure returns (bool) {
        return true;
    }
}