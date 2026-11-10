// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottery.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    address public organizer = makeAddr("organizer");
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy lottery by organizer
        vm.prank(organizer);
        lottery = new Lottery();

        // Fund contract with 1 ETH
        vm.deal(address(lottery), 1 ether);
    }

    function testSelfdestructFunctionality() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record initial balances
        uint256 initialOrganizerBalance = organizer.balance;
        uint256 initialContractBalance = address(lottery).balance;
        console.log("Initial Organizer Balance:", initialOrganizerBalance);
        console.log("Initial Contract Balance:", initialContractBalance);

        console.log("--- Trigger Operation: destroy() ---");
        // Destroy contract as organizer
        vm.prank(organizer);
        lottery.destroy();

        console.log("--- AFTER-Trigger State ---");
        // Record post-destruction balances
        uint256 postOrganizerBalance = organizer.balance;
        uint256 postContractBalance = address(lottery).balance;
        console.log("Post-trigger Organizer Balance:", postOrganizerBalance);
        console.log("Post-trigger Contract Balance:", postContractBalance);

        // Check balance changes
        bool organizerBalanceIncreased = (postOrganizerBalance == initialOrganizerBalance + initialContractBalance);
        bool contractBalanceZero = (postContractBalance == 0);
        
        console.log("Organizer balance increased by contract amount:", organizerBalanceIncreased ? "YES" : "NO");
        console.log("Contract balance reduced to zero:", contractBalanceZero ? "YES" : "NO");

        // Conditionally print final verdict
        if (organizerBalanceIncreased && contractBalanceZero) {
            console.log("Vulnerability Exists: Selfdestruct function transfers contract funds to organizer");
        } else {
            console.log("Vulnerability not Exist: Funds transfer did not occur as expected");
        }
    }

    function testDestroyUnauthorized() public {
        // Non-organizer should not be able to call destroy
        console.log("--- Testing Unauthorized Destruction ---");
        vm.prank(user);
        vm.expectRevert(); // Expect any revert
        lottery.destroy();
        console.log("Unauthorized access prevented - no vulnerability");
    }
}