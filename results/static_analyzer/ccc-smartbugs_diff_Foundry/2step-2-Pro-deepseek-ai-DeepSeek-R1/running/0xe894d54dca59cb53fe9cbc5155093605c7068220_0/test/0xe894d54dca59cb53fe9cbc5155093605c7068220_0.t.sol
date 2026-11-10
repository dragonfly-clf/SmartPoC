// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract FailingToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract AirDropTest is Test {
    airDrop public airdrop;
    FailingToken public failingToken;
    address token;
    address[] receivers;
    address constant owner = address(0x1);
    address constant from = address(0x2);
    
    function setUp() public {
        airdrop = new airDrop();
        failingToken = new FailingToken();
        token = address(failingToken);
        
        receivers = new address[](2);
        receivers[0] = address(0x3);
        receivers[1] = address(0x4);
    }

    function test_missingReturnValueCheck() public {
        // Record initial state
        uint initialDrops = airdrop.totalDrops();
        uint initialTokens = airdrop.totalTokensDistributed();
        uint initialUserDrops = airdrop.userDropCount(owner);

        // Log BEFORE-Trigger state
        console.log("--- BEFORE-Trigger State ---");
        console.log("totalDrops:", initialDrops);
        console.log("totalTokensDistributed:", initialTokens);
        console.log("userDropCount(owner):", initialUserDrops);

        console.log("--- Trigger Operation ---");
        console.log("Executing airdrop.transfer with failing token (always returns false)");
        
        // Execute airdrop with failing token, called by owner
        vm.prank(owner);
        airdrop.transfer(from, token, receivers, 100, 18);
        console.log("Airdrop executed with failing token transfers");

        console.log("--- AFTER-Trigger State ---");
        // Record state after airdrop operation
        uint afterDrops = airdrop.totalDrops();
        uint afterTokens = airdrop.totalTokensDistributed();
        uint afterUserDrops = airdrop.userDropCount(owner);
        console.log("totalDrops:", afterDrops);
        console.log("totalTokensDistributed:", afterTokens);
        console.log("userDropCount(owner):", afterUserDrops);

        // Check if state changed unexpectedly
        bool dropChanged = afterDrops != initialDrops;
        bool tokensChanged = afterTokens != initialTokens;
        bool userDropsChanged = afterUserDrops != initialUserDrops;
        bool stateChanged = dropChanged || tokensChanged || userDropsChanged;
        
        console.log("--- State Comparison Verdict ---");
        console.log("totalDrops changed? %s", dropChanged ? "YES" : "NO");
        console.log("totalTokensDistributed changed? %s", tokensChanged ? "YES" : "NO");
        console.log("userDropCount changed? %s", userDropsChanged ? "YES" : "NO");
        console.log("Overall state changed? %s", stateChanged ? "YES - VULNERABLE" : "NO - SECURE");
        
        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: State variables updated despite failed transfers");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after failed transfers");
        }
    }
}