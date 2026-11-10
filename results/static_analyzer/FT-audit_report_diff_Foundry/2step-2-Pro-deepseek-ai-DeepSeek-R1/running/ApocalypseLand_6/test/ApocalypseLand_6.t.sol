// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ApocalypseLand.sol";

contract ApocalypseLandTest is Test {
    ApocalypseLand token;
    address owner = address(0x1);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new ApocalypseLand();
        // Set auth addresses to satisfy contract authorization
        token.setAuth(owner, owner);
        vm.stopPrank();
    }

    function testReferEthInputValidationBypass() public {
        vm.startPrank(owner);
        console.log("--- BEFORE-Trigger Query ---");
        (,,, uint256 saleMaxBlockInitial, , , ) = token.getBlock();
        console.log("Initial saleMaxBlock value:", saleMaxBlockInitial);
        
        // Prepare auth for config change
        token.authNum(1);
        
        console.log("--- Trigger Set saleMaxBlock=0 ---");
        // Attempt setting saleMaxBlock (tag=9) to invalid value 0
        token.set(9, 0);
        
        console.log("--- AFTER-Trigger Query ---");
        (,,, uint256 saleMaxBlockAfter, , , ) = token.getBlock();
        console.log("Post-attack saleMaxBlock value:", saleMaxBlockAfter);
        
        // Final verification and vulnerability conclusion
        if (saleMaxBlockAfter == 0) {
            console.log("Vulnerability Exists: saleMaxBlock set to invalid value (0) without validation");
        } else {
            console.log("Vulnerability not Exist: saleMaxBlock not changed to 0 after attack");
        }
        vm.stopPrank();
    }
}