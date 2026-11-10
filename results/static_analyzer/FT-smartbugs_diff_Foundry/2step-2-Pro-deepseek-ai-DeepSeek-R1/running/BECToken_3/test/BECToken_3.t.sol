// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenOwnershipTest is Test {
    BecToken public token;
    address public deployer;

    function setUp() public {
        deployer = address(this);
        token = new BecToken();
    }

    function test_transferOwnershipToContractItself() public {
        console.log("--- BEFORE-Trigger Owner ---");
        // Capture initial owner state before any action
        address preTransferOwner = token.owner();
        console.log("Pre-transfer owner: %s", preTransferOwner);
        assertEq(preTransferOwner, address(this), "Pre-transfer owner should be deployer");

        console.log("--- Trigger transferOwnership ---");
        // Critical vulnerability action: transfer ownership
        token.transferOwnership(address(token));

        console.log("--- AFTER-Trigger Owner ---");
        // Capture owner state after attack
        address postTransferOwner = token.owner();
        console.log("Post-transfer owner: %s", postTransferOwner);

        // Check vulnerability conditions
        bool ownerChanged = (postTransferOwner != preTransferOwner);
        bool ownerIsContract = (postTransferOwner == address(token));

        console.log("Vulnerability Analysis:");
        console.log("1. Owner changed: %s", ownerChanged ? "Yes" : "No");
        console.log("2. Owner set to contract: %s", ownerIsContract ? "Yes" : "No");

        // Attempt protected function using new owner state
        console.log("Test function call with compromised owner");
        try token.pause() {
            console.log("Function executed successfully - vulnerability not exploited");
        } catch {
            console.log("Function reverted - vulnerability exploited");
        }

        // Final vulnerability verdict
        if (ownerChanged && ownerIsContract) {
            console.log("Vulnerability Exists: Ownership successfully transferred to contract address");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed or not set to contract");
        }
    }
}