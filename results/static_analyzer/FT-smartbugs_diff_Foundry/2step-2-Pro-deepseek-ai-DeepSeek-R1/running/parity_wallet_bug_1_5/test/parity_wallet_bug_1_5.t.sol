// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_1.sol";

contract WalletInputValidationTest is Test {
    WalletLibrary public walletLib;
    
    address[] validOwners = [address(0x123), address(0x124)];
    uint validRequired = 2;
    uint validDayLimit = 100;
    
    function setUp() public {
        walletLib = new WalletLibrary();
    }
    
    // Helper to log key state variables
    function logState(string memory context) internal view {
        console2.log("---", context, "- State ---");
        console2.log("m_numOwners:", walletLib.m_numOwners());
        console2.log("m_required:", walletLib.m_required());
        console2.log("m_dailyLimit:", walletLib.m_dailyLimit());
    }
    
    // Test successful initialization with valid parameters
    function testValidInitialization() public {
        logState("BEFORE-Trigger (Valid Initialization)");
        walletLib.initWallet(validOwners, validRequired, validDayLimit);
        logState("AFTER-Trigger (Valid Initialization)");
        
        // Fix: Account for the additional owner in actual implementation
        assertEq(walletLib.m_numOwners(), 3, "Valid: Owners count mismatch (expected 2 passed + 1 implicit)");
        assertEq(walletLib.m_required(), 2, "Valid: Confirmations mismatch");
        assertEq(walletLib.m_dailyLimit(), 100, "Valid: Daily limit mismatch");
    }
    
    // Test initialization with 0 address in owners array
    function testZeroAddressOwner() public {
        logState("BEFORE-Trigger (Zero Address)");
        address[] memory ownersWithZero = new address[](3);
        ownersWithZero[0] = address(0x123);
        ownersWithZero[1] = address(0);
        ownersWithZero[2] = address(0x125);
        
        (bool success,) = address(walletLib).call(
            abi.encodeWithSignature(
                "initWallet(address[],uint256,uint256)",
                ownersWithZero,
                validRequired,
                validDayLimit
            )
        );
        
        logState("AFTER-Trigger (Zero Address)");
        console2.log("Call Result:", success ? "Success" : "Reverted");

        if (success) {
            console2.log("Vulnerability Exists: Zero address owner allowed");
        } else {
            console2.log("Vulnerability not Exist: Reverted (expected)");
        }
    }
    
    // Test initialization with required confirmations > owners
    function testExcessRequiredConfirmations() public {
        logState("BEFORE-Trigger (Excess Confirmations)");
        address[] memory singleOwner = new address[](1);
        singleOwner[0] = address(0x123);
        
        (bool success,) = address(walletLib).call(
            abi.encodeWithSignature(
                "initWallet(address[],uint256,uint256)",
                singleOwner,
                3,  // Invalid required > owners
                validDayLimit
            )
        );
        
        logState("AFTER-Trigger (Excess Confirmations)");
        console2.log("Call Result:", success ? "Success" : "Reverted");

        if (success) {
            console2.log("Vulnerability Exists: Excess confirmations allowed");
        } else {
            console2.log("Vulnerability not Exist: Reverted (expected)");
        }
    }
    
    // Test initialization with 0 daily limit
    function testZeroDailyLimit() public {
        logState("BEFORE-Trigger (Zero Daily Limit)");

        (bool success,) = address(walletLib).call(
            abi.encodeWithSignature(
                "initWallet(address[],uint256,uint256)",
                validOwners,
                validRequired,
                0  // Zero daily limit
            )
        );
        
        logState("AFTER-Trigger (Zero Daily Limit)");
        console2.log("Call Result:", success ? "Success" : "Reverted");

        if (success) {
            console2.log("Vulnerability Exists: Zero daily limit allowed");
        } else {
            console2.log("Vulnerability not Exist: Reverted (expected)");
        }
    }
}