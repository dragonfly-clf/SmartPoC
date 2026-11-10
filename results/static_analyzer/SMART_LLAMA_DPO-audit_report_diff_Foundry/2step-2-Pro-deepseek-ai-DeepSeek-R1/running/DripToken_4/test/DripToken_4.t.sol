// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DripToken.sol";

contract PrivilegeEscalationTest is Test {
    DripToken public token;
    address public constant originalOwner = address(0x1);
    address public constant attacker = address(0x2);
    
    // Mock addresses
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_WETH = address(0x3);
    address constant MOCK_FACTORY = address(0x4);
    address constant MOCK_PAIR = address(0x5);

    function setUp() public {
        // Precompute token address before deployment
        address computedToken = computeCreateAddress(
            originalOwner,
            vm.getNonce(originalOwner)
        );
        
        // Mock router factory() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair() call with computed token address
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature(
                "createPair(address,address)", 
                computedToken, 
                MOCK_WETH
            ),
            abi.encode(MOCK_PAIR)
        );
        
        // Deploy token
        vm.prank(originalOwner);
        token = new DripToken();
    }

    function testPrivilegeEscalationVulnerability() public {
        // Differential verification variables
        bool vulnerabilityExists = true;
        string memory reason = "";

        // Step 1: Verify initial ownership
        console.log("--- BEFORE Step1: Initial ownership check ---");
        address preOwner = token.owner();
        console.log("Owner address: %s", preOwner);
        assertEq(preOwner, originalOwner, "Initial owner should be originalOwner");

        // Step 2: Ownership transfer to attacker
        console.log("--- TRIGGER Step1: Owner transfers to attacker ---");
        vm.prank(originalOwner);
        token.transferOwnership(attacker);
        
        console.log("--- AFTER Step1: Ownership transfer result ---");
        address postOwner = token.owner();
        console.log("Owner address: %s", postOwner);
        assertEq(postOwner, attacker, "Ownership should be transferred to attacker");

        // Step 3: Transfer back to original owner
        console.log("--- BEFORE Step2: Pre-transfer-back check ---");
        address ownerBeforeTransferBack = token.owner();
        console.log("Owner address: %s", ownerBeforeTransferBack);

        console.log("--- TRIGGER Step2: Attacker transfers back ---");
        vm.prank(attacker);
        token.transferOwnership(originalOwner);
        
        console.log("--- AFTER Step2: Post-transfer-back check ---");
        address ownerAfterTransferBack = token.owner();
        console.log("Owner address: %s", ownerAfterTransferBack);
        assertEq(ownerAfterTransferBack, originalOwner, "Ownership should revert to original owner");

        // Step 4: Attempt to regain ownership
        console.log("--- BEFORE Step3: Pre-regain check ---");
        address ownerBeforeRegain = token.owner();
        console.log("Owner address: %s", ownerBeforeRegain);

        console.log("--- TRIGGER Step3: Attacker attempts to regain ownership ---");
        vm.prank(originalOwner);
        token.transferOwnership(attacker);
        
        console.log("--- AFTER Step3: Post-regain check ---");
        address finalOwner = token.owner();
        console.log("Owner address: %s", finalOwner);
        assertEq(finalOwner, attacker, "Ownership transferred to attacker");

        // Differential comparison verdict
        console.log("--- Differential Validation Results ---");
        console.log("Initial transfer (attacker gain): %s -> %s", originalOwner, attacker);
        console.log("Transfer back (original regain): %s -> %s", attacker, originalOwner);
        console.log("Final transfer (attacker regain): %s -> %s", originalOwner, attacker);
        
        // Vulnerability does NOT exist - all transfers were authorized
        vulnerabilityExists = false;
        reason = "All ownership changes were initiated by current owners";
        console.log("Vulnerability not Exist:", reason);

        // Final verdict output (must be last line)
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists:", reason);
        } else {
            console.log("Vulnerability not Exist:", reason);
        }
    }
}