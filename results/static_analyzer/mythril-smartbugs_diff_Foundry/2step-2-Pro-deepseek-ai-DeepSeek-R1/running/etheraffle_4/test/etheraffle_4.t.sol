// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract EthraffleTest is Test {
    Ethraffle_v4b public raffle;
    address public deployer = vm.addr(1);
    address public nonOwner = vm.addr(2);

    function setUp() public {
        vm.startPrank(deployer);
        raffle = new Ethraffle_v4b();
        vm.stopPrank();
    }

    // Test feeAddress can toggle pause state
    function testFeeAddressCanTogglePause() public {
        // Query initial pause state
        bool initialPaused = raffle.paused();
        console2.log("--- BEFORE-Trigger STATE: raffle.paused() ---");
        console2.log("Initial paused state:", initialPaused);

        // Trigger pause toggle
        console2.log("--- Trigger: deployer calls togglePause() ---");
        vm.prank(deployer);
        raffle.togglePause();
        
        // Query final pause state
        bool finalPaused = raffle.paused();
        console2.log("--- AFTER-Trigger STATE: raffle.paused() ---");
        console2.log("Final paused state:", finalPaused);
        
        // Validate state changed (expected behavior)
        require(
            initialPaused != finalPaused,
            "Owner failed to toggle pause state. Test anomaly."
        );
    }

    // Test non-owner cannot toggle pause
    function testNonFeeAddressCannotTogglePause() public {
        // Query initial pause state
        bool initialPaused = raffle.paused();
        console2.log("--- BEFORE-Trigger STATE: raffle.paused() ---");
        console2.log("Initial paused state:", initialPaused);
        
        // Trigger unauthorized pause toggle
        console2.log("--- Trigger: nonOwner calls togglePause() ---");
        vm.prank(nonOwner);
        raffle.togglePause();
        
        // Query final pause state
        bool finalPaused = raffle.paused();
        console2.log("--- AFTER-Trigger STATE: raffle.paused() ---");
        console2.log("Final paused state:", finalPaused);
        
        // Determine vulnerability existence
        if (initialPaused != finalPaused) {
            console2.log("Vulnerability Exists: non-fee address successfully changed pause state");
        } else {
            console2.log("Vulnerability not Exist: non-fee address cannot change pause state");
        }
    }
}