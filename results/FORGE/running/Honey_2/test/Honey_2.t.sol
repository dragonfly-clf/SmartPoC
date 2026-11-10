// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/honeyToken.sol";

contract HoneyTokenTest is Test {
    honeyToken token;
    address owner = address(this); // Test contract as owner
    address constant recipient = address(0x123);

    // Token deployment parameters
    string constant NAME = "TestToken";
    string constant SYMBOL = "TKN";
    uint256 constant DECIMALS = 18;
    uint256 constant SUPPLY = 1000000 * (10**18); // 1 million tokens
    uint256 constant TX_FEE = 1;
    uint256 constant BURN_FEE = 1;
    uint256 constant CHARITY_FEE = 1;

    function setUp() public {
        // Deploy token with test contract as owner
        token = new honeyToken(
            NAME,
            SYMBOL,
            DECIMALS,
            SUPPLY,
            TX_FEE,
            BURN_FEE,
            CHARITY_FEE,
            address(0x1),
            owner
        );
    }

    function testGetCurrentSupplyOutOfGas() public {
        // Exclude a large number of accounts (enough to trigger OOG)
        console.log("--- BEFORE-Trigger ---");
        console.log("Excluding 200 accounts to prepare for OOG condition...");
        uint256 count = 200;
        for (uint256 i; i < count; i++) {
            token.excludeAccount(address(uint160(0x10000 + i)));
        }

        // Setup transfer (owner has all initial tokens)
        uint256 transferAmount = 1 * (10**DECIMALS);
        console.log("Preparing token transfer with low gas limit");

        console.log("--- Trigger: Low Gas Transfer ---");
        uint256 lowGasLimit = 100000; // Arbitrarily low gas limit
        (bool success, ) = address(token).call{gas: lowGasLimit}(
            abi.encodeWithSelector(
                token.transfer.selector,
                recipient,
                transferAmount
            )
        );
        
        console.log("--- AFTER-Trigger ---");
        console.log("Transfer result:", success ? "Succeeded" : "Failed");
        
        // Vulnerability verdict based on transfer success/failure
        if (success) {
            console.log("Vulnerability not Exist: Transfer succeeded unexpectedly with low gas limit");
        } else {
            console.log("Vulnerability Exists: Transfer failed due to OOG as expected");
        }

        // Final verification and test outcome
        assertFalse(success, "Transfer should have reverted due to OOG");
    }
}