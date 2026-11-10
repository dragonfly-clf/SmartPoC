// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract PieWithdrawTest is Test {
    Pie pieContract;
    address constant HARDCODED_ADDRESS = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;
    address deployer = makeAddr("deployer");
    address nonOwner = makeAddr("nonOwner");
    
    function setUp() public {
        vm.startPrank(deployer);
        pieContract = new Pie();
        vm.stopPrank();
        
        // Fund the contract
        vm.deal(address(pieContract), 1 ether);
    }

    function testWithdrawDrainsContract() public {
        // Get initial state values
        uint256 initialBalance = address(pieContract).balance;
        uint256 initialTotalWithdrawals = pieContract.totalWithdrawals();
        address initialOwner = pieContract.Owner();

        console2.log("--- BEFORE-Trigger Withdraw ---");
        console2.log("Initial Contract Balance (wei):", initialBalance);
        console2.log("Initial Total Withdrawals (wei):", initialTotalWithdrawals);
        console2.log("Initial Owner:", initialOwner);

        console2.log("--- Trigger Withdraw by HARDCODED_ADDRESS ---");
        // Call withdraw from hardcoded address
        vm.prank(HARDCODED_ADDRESS);
        pieContract.withdraw();

        // Get post-state values
        uint256 postBalance = address(pieContract).balance;
        uint256 postTotalWithdrawals = pieContract.totalWithdrawals();
        address postOwner = pieContract.Owner();

        console2.log("--- AFTER-Trigger Withdraw ---");
        console2.log("Final Contract Balance (wei):", postBalance);
        console2.log("Final Total Withdrawals (wei):", postTotalWithdrawals);
        console2.log("Final Owner:", postOwner);
        console2.log("");

        // Differential analysis
        console2.log("--- Vulnerability Verification ---");
        console2.log("Balance change: %d to %d", initialBalance, postBalance);
        console2.log("Withdrawals change: %d to %d", initialTotalWithdrawals, postTotalWithdrawals);
        console2.log("Owner unchanged: %s", initialOwner == postOwner ? "YES" : "NO");

        // Vulnerability conditions
        bool balanceDrained = (postBalance == 0);
        bool withdrawalsIncreased = (postTotalWithdrawals == initialTotalWithdrawals + initialBalance);
        bool ownerUnchanged = (initialOwner == postOwner);
        bool exploitSuccess = balanceDrained && withdrawalsIncreased && ownerUnchanged;

        // Final verdict (exactly one line at end)
        if (exploitSuccess) {
            console2.log("Vulnerability Exists: HARDCODED_ADDRESS successfully bypassed authorization and drained funds");
        } else {
            console2.log("Vulnerability not Exist: State changes did not show expected exploit pattern");
        }
    }
    
    function testOwnerWithdraw() public {
        // Simulate deployer being the original owner
        vm.prank(deployer);
        pieContract.withdraw();
        
        // Verify contract balance was drained
        assertEq(address(pieContract).balance, 0, "Contract not drained by deployer");
    }
    
    function testNonOwnerCannotWithdraw() public {
        // Non-owner attempts to withdraw
        vm.prank(nonOwner);
        vm.expectRevert();
        pieContract.withdraw();
    }
    
    function testNoFundsReceiveFunction() public {
        // Withdraw all funds from contract
        vm.prank(deployer);
        pieContract.withdraw();
        
        // Verify receiving ether fails due to insufficient funds
        vm.expectRevert();
        payable(address(pieContract)).transfer(1 wei);
    }
}