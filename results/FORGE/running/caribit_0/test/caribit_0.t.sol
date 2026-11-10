// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CariBit.sol";

contract MockPinkAntiBot {
    function setTokenOwner(address) external {
        // Empty mock implementation
    }
}

contract CariBitFeeTest is Test {
    CariBit token;
    address owner = address(0x1);
    
    // Hardcoded address from CariBit contract
    address constant PINK_ANTI_BOT = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002;
    
    // Helper to get runtime bytecode of an address
    function getRuntimeBytecode(address _addr) public view returns (bytes memory code) {
        assembly {
            // Retrieve code size
            let size := extcodesize(_addr)
            // Allocate output byte array
            code := mload(0x40)
            // Update free memory pointer
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // Store length
            mstore(code, size)
            // Copy actual code
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
    }

    function setUp() public {
        // Deploy mock contract
        MockPinkAntiBot mock = new MockPinkAntiBot();
        
        // Get its runtime bytecode
        bytes memory code = getRuntimeBytecode(address(mock));
        
        // Set mock code to PinkAntiBot address
        vm.etch(PINK_ANTI_BOT, code);

        // Deploy token contract
        vm.startPrank(owner);
        token = new CariBit();
        vm.stopPrank();
    }

    function testFeeExceeds25Percent() public {
        uint256 OVER_LIMIT_FEE = 26; // 26% exceeds allowed limit
        
        console.log("--- BEFORE-Trigger Fee State ---");
        // Capture initial state values
        uint256 initialMarketingFee = token.marketingFee();
        uint256 initialTotalFees = token.totalFees();
        console.log("Initial Marketing Fee:", initialMarketingFee, "%");
        console.log("Initial Total Fees:", initialTotalFees, "%");

        // Verify initial fees are below limit
        assertLe(initialTotalFees, 25, "Initial fees exceed 25% limit");

        console.log("--- Trigger SetMarketingFee ---");
        // Owner sets marketing fee to 26% exceeding limit
        vm.prank(owner);
        token.setMarketingFee(OVER_LIMIT_FEE);

        console.log("--- AFTER-Trigger Fee State ---");
        // Capture post-trigger state values
        uint256 newMarketingFee = token.marketingFee();
        uint256 newTotalFees = token.totalFees();
        console.log("New Marketing Fee:", newMarketingFee, "%");
        console.log("New Total Fees:", newTotalFees, "%");

        // Check vulnerability conditions
        bool marketingFeeUpdated = (newMarketingFee == OVER_LIMIT_FEE);
        bool feesExceedLimit = (newTotalFees > 25);
        bool vulnerabilityExists = marketingFeeUpdated && feesExceedLimit;

        // Final exploit verification
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees were set to exceed 25% limit");
        } else {
            console.log("Vulnerability not Exist: Fee limits are enforced");
        }
    }
}