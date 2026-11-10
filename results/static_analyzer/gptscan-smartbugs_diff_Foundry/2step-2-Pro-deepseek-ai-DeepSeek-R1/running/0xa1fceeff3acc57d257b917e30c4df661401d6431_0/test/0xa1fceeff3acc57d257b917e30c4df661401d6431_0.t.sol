// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false; // Return false to simulate transfer failure
    }
}

contract AirDropContractTest is Test {
    AirDropContract public airDrop;
    MockToken public token;
    address constant USER = address(0x1);
    address constant RECIPIENT = address(0x2);
    uint256 constant AMOUNT = 1000;

    function setUp() public {
        airDrop = new AirDropContract();
        token = new MockToken();
    }

    function testTransferWithoutApprovalUpdatesStats() public {
        // Prepare inputs
        address[] memory recipients = new address[](1);
        recipients[0] = RECIPIENT;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = AMOUNT;

        console2.log("--- BEFORE-Trigger Transfer ---");
        (uint preAirdropCount, uint preTokens) = airDrop.getUserStats(RECIPIENT);
        uint preTotalAirdrops = airDrop.totalAirdrops();
        uint preTotalTokensDistributed = airDrop.totalTokensDistributed();
        
        console2.log("Pre-state of RECIPIENT:");
        console2.log("  userAirdropCount:", preAirdropCount);
        console2.log("  tokensReceived:", preTokens);
        console2.log("Pre-state of GLOBAL:");
        console2.log("  totalAirdrops:", preTotalAirdrops);
        console2.log("  totalTokensDistributed:", preTotalTokensDistributed);

        console2.log("--- Trigger Transfer ---");
        vm.prank(USER);
        airDrop.transfer(address(token), recipients, amounts);

        console2.log("--- AFTER-Trigger Transfer ---");
        (uint postAirdropCount, uint postTokens) = airDrop.getUserStats(RECIPIENT);
        uint postTotalAirdrops = airDrop.totalAirdrops();
        uint postTotalTokensDistributed = airDrop.totalTokensDistributed();
        
        console2.log("Post-state of RECIPIENT:");
        console2.log("  userAirdropCount:", postAirdropCount);
        console2.log("  tokensReceived:", postTokens);
        console2.log("Post-state of GLOBAL:");
        console2.log("  totalAirdrops:", postTotalAirdrops);
        console2.log("  totalTokensDistributed:", postTotalTokensDistributed);

        console2.log("--- Differential Verification ---");
        bool userStatsChanged = (postAirdropCount != preAirdropCount) || (postTokens != preTokens);
        bool globalStatsChanged = (postTotalAirdrops != preTotalAirdrops) || (postTotalTokensDistributed != preTotalTokensDistributed);
        bool statsChanged = userStatsChanged || globalStatsChanged;
        
        console2.log("RECIPIENT state changed:", userStatsChanged ? "YES" : "NO");
        console2.log("GLOBAL state changed:", globalStatsChanged ? "YES" : "NO");
        console2.log("Did statistics update despite failed transfer?", statsChanged ? "YES" : "NO");

        if (statsChanged) {
            console2.log("Vulnerability Exists: Statistics updated despite transferFrom returning false");
        } else {
            console2.log("Vulnerability not Exist: Statistics remain unchanged after failed transfer");
        }
    }
}