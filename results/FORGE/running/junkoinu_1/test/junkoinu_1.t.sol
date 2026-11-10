// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/junkoInu.sol";

contract JunkoInuTest is Test {
    junkoInu public token;
    address owner = address(this);
    address fakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = 0x1111111111111111111111111111111111111111;
    address mockWETH = 0x2222222222222222222222222222222222222222;
    address mockPair = 0x3333333333333333333333333333333333333333;

    function setUp() public {
        // Mock router: return factory address
        vm.mockCall(
            fakeRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router: return WETH address
        vm.mockCall(
            fakeRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory: createPair returns mockPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token
        token = new junkoInu();
    }

    function test_SetUnlimitedTaxFee() public {
        // Track results for each exploit step
        bool set100Success = false;
        bool set10000Success = false;
        bool setMaxSuccess = false;
        uint256 maxValue = type(uint256).max;

        //=== Step 1: Set tax fee to 100 (100%) ===
        console.log("--- BEFORE (Step 1) ---");
        uint256 beforeFee1 = token._taxFee();
        console.log("_taxFee state BEFORE:", beforeFee1);
        
        console.log("\n--- TRIGGER (Step 1): setTaxFeePercent(100) ---");
        token.setTaxFeePercent(100);
        
        console.log("\n--- AFTER (Step 1) ---");
        uint256 afterFee1 = token._taxFee();
        console.log("_taxFee state AFTER:", afterFee1);
        
        // Differential check
        if (afterFee1 == 100) {
            console.log("RESULT (Step 1): PASS - State changed to 100");
            set100Success = true;
        } else {
            console.log("RESULT (Step 1): FAIL - State not set properly");
        }

        //=== Step 2: Set tax fee to 10000 (10,000%) ===
        console.log("\n--- BEFORE (Step 2) ---");
        uint256 beforeFee2 = token._taxFee();
        console.log("_taxFee state BEFORE:", beforeFee2);
        
        console.log("\n--- TRIGGER (Step 2): setTaxFeePercent(10000) ---");
        token.setTaxFeePercent(10000);
        
        console.log("\n--- AFTER (Step 2) ---");
        uint256 afterFee2 = token._taxFee();
        console.log("_taxFee state AFTER:", afterFee2);
        
        // Differential check
        if (afterFee2 == 10000) {
            console.log("RESULT (Step 2): PASS - State changed to 10000");
            set10000Success = true;
        } else {
            console.log("RESULT (Step 2): FAIL - State not set properly");
        }

        //=== Step 3: Set tax fee to max uint256 value ===
        console.log("\n--- BEFORE (Step 3) ---");
        uint256 beforeFee3 = token._taxFee();
        console.log("_taxFee state BEFORE:", beforeFee3);
        
        console.log("\n--- TRIGGER (Step 3): setTaxFeePercent(max) ---");
        token.setTaxFeePercent(maxValue);
        
        console.log("\n--- AFTER (Step 3) ---");
        uint256 afterFee3 = token._taxFee();
        console.log("_taxFee state AFTER:", afterFee3);
        
        // Differential check
        if (afterFee3 == maxValue) {
            console.log("RESULT (Step 3): PASS - State changed to max value");
            setMaxSuccess = true;
        } else {
            console.log("RESULT (Step 3): FAIL - Max value not set");
        }

        // Final verdict
        console.log("\n=== FINAL VERDICT ===");
        if (set100Success && set10000Success && setMaxSuccess) {
            console.log("Vulnerability Exists: Owner can set tax fee to any arbitrary value");
        } else {
            console.log("Vulnerability not Exist: Some tax fee settings did not succeed");
        }
    }
    
    function test_NonOwnerCannotSetFee() public {
        address user = makeAddr("regularUser");
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(100);
    }
}