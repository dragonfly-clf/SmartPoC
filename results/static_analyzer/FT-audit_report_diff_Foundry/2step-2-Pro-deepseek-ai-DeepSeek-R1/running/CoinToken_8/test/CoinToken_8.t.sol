// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MaliciousReceiver {
    fallback() external payable {
        revert("MaliciousReceiver: Always reverting");
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789); // Dummy pair address
    }
}

contract MockRouter {
    MockFactory public immutable factory;
    
    constructor() {
        factory = new MockFactory();
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract CoinTokenTransferTest is Test {
    address immutable owner = address(0x123);
    MockRouter mockRouter;

    function setUp() public {
        mockRouter = new MockRouter();
    }

    function testConstructorTransferFailure() public {
        console.log("--- BEFORE-Trigger deployment ---");
        console.log("Deploying with malicious receivers...");

        MaliciousReceiver maliciousLpReceiver = new MaliciousReceiver();
        MaliciousReceiver marketingReceiver = new MaliciousReceiver();
        
        console.log("--- Trigger deployment ---");
        // Attempt deployment with failing LP receiver
        bool deploymentSucceeded;
        try new CoinToken{value: 1 ether}(
            "FailToken", 
            "FAIL", 
            1_000_000 * 10**9,   // _ts
            3,                    // _tax
            2,                    // _bb
            1,                    // _mkt
            address(marketingReceiver),  // _ma (marketing)
            address(mockRouter),   // _ru (router)
            address(maliciousLpReceiver) // _lp (fails transfer)
        ) {
            deploymentSucceeded = true;
        } catch {
            deploymentSucceeded = false;
        }

        console.log("--- AFTER-Trigger deployment ---");
        if (deploymentSucceeded) {
            console.log("Vulnerability not Exist: Deployment unexpectedly succeeded with malicious receivers");
        } else {
            console.log("Vulnerability Exists: Deployment reverted due to malicious receiver");
        }
    }
}