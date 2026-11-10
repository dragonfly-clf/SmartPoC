// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract MaliciousContract {
    bool public called;
    uint256 public value;

    function maliciousFunction(uint256 _val) external payable {
        called = true;
        value = _val;
    }

    function dangerousOperation() external {
        // This could be any dangerous operation
        called = true;
    }
}

contract WalletArbitraryCallTest is Test {
    WalletLibrary wallet;
    MaliciousContract malicious;
    address owner = address(1);

    function setUp() public {
        vm.startPrank(owner);
        // Initialize wallet with the test contract as owner
        wallet = new WalletLibrary();
        address[] memory owners = new address[](1);
        owners[0] = owner;
        wallet.initWallet(owners, 1, 0); // Only 1 confirmation needed
        vm.stopPrank();

        malicious = new MaliciousContract();
    }

    function test_ArbitraryCall() public {
        console.log("--- BEFORE-Trigger State ---");
        bool preCalled = malicious.called();
        uint256 preValue = malicious.value();
        console.log("Pre-trigger state: called=%s, value=%s", preCalled, preValue);

        console.log("--- Trigger ArbitraryCall ---");
        vm.startPrank(owner);
        // Prepare call data for maliciousFunction(123)
        bytes memory data = abi.encodeWithSignature("maliciousFunction(uint256)", 123);
        
        // Execute the malicious call
        wallet.execute(address(malicious), 0, data);
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        bool postCalled = malicious.called();
        uint256 postValue = malicious.value();
        console.log("Post-trigger state: called=%s, value=%s", postCalled, postValue);

        // Verify malicious contract state was changed
        assertTrue(malicious.called(), "Malicious function not called");
        assertEq(malicious.value(), 123, "Malicious function parameter not set");

        // Vulnerability verdict
        if (postCalled != preCalled || postValue != preValue) {
            console.log("Vulnerability Exists: Arbitrary call successfully changed external contract state");
        } else {
            console.log("Vulnerability not Exist: External contract state remained unchanged");
        }
    }

    function test_ArbitraryDangerousCall() public {
        console.log("--- BEFORE-Trigger State ---");
        bool preCalled = malicious.called();
        console.log("Pre-trigger state: called=%s", preCalled);

        console.log("--- Trigger ArbitraryDangerousCall ---");
        vm.startPrank(owner);
        // Prepare call data for dangerousOperation()
        bytes memory data = abi.encodeWithSignature("dangerousOperation()");
        
        // Execute the dangerous call
        wallet.execute(address(malicious), 0, data);
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        bool postCalled = malicious.called();
        console.log("Post-trigger state: called=%s", postCalled);

        // Verify the dangerous operation was executed
        assertTrue(malicious.called(), "Dangerous operation not executed");

        // Vulnerability verdict
        if (postCalled != preCalled) {
            console.log("Vulnerability Exists: Dangerous operation was successfully executed");
        } else {
            console.log("Vulnerability not Exist: External contract state remained unchanged");
        }
    }
}