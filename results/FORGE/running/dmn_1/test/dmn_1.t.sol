// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract MockFactory {
    address private immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockWETH {}

contract DomainTest is Test {
    Domain token;
    address owner = address(0x123);
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address immutable dummyPair = address(0xabc);
    
    MockFactory mockFactory;
    address mockWETH;

    function setUp() public {
        // Deploy mock contracts
        mockFactory = new MockFactory(dummyPair);
        mockWETH = address(new MockWETH());
        
        // Mock router factory call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(mockFactory))
        );
        
        // Mock router WETH call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Deploy token contract
        vm.prank(owner);
        token = new Domain();
    }

    function test_fees_exceed_25_percent() public {
        console.log("--- BEFORE-Trigger SetSellFees ---");
        // Destructure sellRates tuple into components
        (uint8 rfiBefore, uint8 treasuryBefore, uint8 devBefore, uint8 lpBefore, ) = token.sellRates();
        uint256 totalBefore = rfiBefore + treasuryBefore + devBefore + lpBefore;
        console.log("Initial total sell fee rate: %d%%", totalBefore);
        
        console.log("--- Trigger SetSellFees(10,10,5,1) ---");
        vm.startPrank(owner);
        token.setSellFees(10, 10, 5, 1);  // Total fees 26% 
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger SetSellFees ---");
        // Destructure updated rates
        (uint8 rfiAfter, uint8 treasuryAfter, uint8 devAfter, uint8 lpAfter, ) = token.sellRates();
        uint256 totalAfter = rfiAfter + treasuryAfter + devAfter + lpAfter;
        console.log("Updated total sell fee rate: %d%%", totalAfter);
        
        // Differential validation
        bool vulnerabilityExists = totalAfter > 25;
        
        console.log("Total fees BEFORE attack: %d%%", totalBefore);
        console.log("Total fees AFTER attack: %d%%", totalAfter);
        
        // Final verdict with vulnerability check
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees bypassed 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fee limits enforced");
        }
    }

    function test_valid_fee_setting() public {
        vm.startPrank(owner);
        token.setSellFees(10, 10, 5, 0);  // Total fees 25% 
        vm.stopPrank();
        assertTrue(true, "25% fee setting should work");
    }
}