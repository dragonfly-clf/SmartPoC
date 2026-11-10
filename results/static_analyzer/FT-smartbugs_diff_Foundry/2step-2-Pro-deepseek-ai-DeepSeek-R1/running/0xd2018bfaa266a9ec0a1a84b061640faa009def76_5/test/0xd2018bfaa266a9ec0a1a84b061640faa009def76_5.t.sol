// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract PieGetTest is Test {
    Pie public pie;
    address payable owner;
    address payable user;

    // Add receive function to allow test contract to accept ETH
    receive() external payable {}

    function setUp() public {
        // Deploy the contract
        pie = new Pie();
        
        // Set the user address and fund it
        user = payable(address(0x1234));
        vm.deal(user, 10 ether);
        
        // Set owner to test contract
        owner = payable(address(this));
    }

    function testGetTransfersAllBalance() public {
        // --- BEGIN DIFFERENTIAL VALIDATION ---
        console2.log("--- BEFORE-Trigger Get ---");
        // Pre-trigger state capture
        uint256 prePieBalance = address(pie).balance;
        uint256 preUserBalance = user.balance;
        uint256 preOwnerBalance = owner.balance;
        uint256 preUserDeposit = pie.getUserBalance(user);
        
        console2.log("Pie contract ETH balance:", prePieBalance);
        console2.log("User ETH balance:", preUserBalance);
        console2.log("Owner ETH balance:", preOwnerBalance);
        console2.log("User deposit record:", preUserDeposit);
        
        console2.log("--- Trigger Get (2 ETH deposit) ---");
        // --- END DIFFERENTIAL VALIDATION ---

        // User makes deposit of 2 ether
        vm.prank(user);
        pie.Get{value: 2 ether}();

        // --- BEGIN STATE VERIFICATION & DIFFERENTIAL CHECK ---
        console2.log("--- AFTER-Trigger Get ---");
        // Post-trigger state capture
        uint256 postPieBalance = address(pie).balance;
        uint256 postUserBalance = user.balance;
        uint256 postOwnerBalance = owner.balance;
        uint256 postUserDeposit = pie.getUserBalance(user);
        
        console2.log("Pie contract ETH balance:", postPieBalance);
        console2.log("User ETH balance:", postUserBalance);
        console2.log("Owner ETH balance:", postOwnerBalance);
        console2.log("User deposit record:", postUserDeposit);
        
        // Differential checks
        bool contractBalanceCleared = (postPieBalance == 0);
        bool userBalanceDecreased = (postUserBalance == preUserBalance - 2 ether);
        bool ownerBalanceIncreased = (postOwnerBalance == preOwnerBalance + 2 ether);
        bool depositRecorded = (postUserDeposit == preUserDeposit + 2 ether);
        
        // Vulnerability verification
        bool vulnerabilityExists = contractBalanceCleared && 
                                  userBalanceDecreased && 
                                  ownerBalanceIncreased && 
                                  depositRecorded;
        
        // State change verification
        console2.log("Contract balance cleared (0 ETH):", contractBalanceCleared ? "Yes" : "No");
        console2.log("User balance decreased by 2 ETH:", userBalanceDecreased ? "Yes" : "No");
        console2.log("Owner received 2 ETH:", ownerBalanceIncreased ? "Yes" : "No");
        console2.log("Deposit recorded (+2 ETH):", depositRecorded ? "Yes" : "No");
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Get function transfers contract balance to owner while improperly recording user deposits");
        } else {
            console2.log("Vulnerability not Exist: State changes not matching expected vulnerability pattern");
        }
        // --- END DIFFERENTIAL VALIDATION ---
    }
}