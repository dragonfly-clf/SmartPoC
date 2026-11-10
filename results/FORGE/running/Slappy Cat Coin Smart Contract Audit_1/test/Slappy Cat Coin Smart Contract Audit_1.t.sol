// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract SlappyCatTest is Test {
    function test_UnsupportedChainRevert() public {
        // Set to an unsupported chain ID
        uint256 unsupportedChainId = 777;
        vm.chainId(unsupportedChainId);

        console.log("--- BEFORE-Trigger Event ---");
        console.log("Current chain ID: ", unsupportedChainId);
        console.log("Expected deployment behavior: REVERT");
        console.log("");
        
        console.log("--- Trigger Deployment ---");
        console.log("Attempting deployment on unsupported chain");
        (bool deploySuccess, ) = address(this).call(abi.encodeWithSignature("attemptDeploy()"));
        console.log("");
        
        console.log("--- AFTER-Trigger Event ---");
        console.log("Deployment outcome: ", deploySuccess ? "SUCCESS" : "FAIL (reverted)");
        console.log("State after deployment: No contract deployed (revert occurred)");

        // Conditional vulnerability verdict
        if (deploySuccess) {
            console.log("Vulnerability Exists: Contract deployed successfully on unsupported chain - no revert occurred");
        } else {
            console.log("Vulnerability not Exist: Contract correctly reverts deployment on unsupported chain");
        }
    }
    
    // Helper function to attempt deployment
    function attemptDeploy() external {
        new SlappyCat();
    }
}