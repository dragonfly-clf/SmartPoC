// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoonBoi.sol";

contract MockWETH {
    // Minimal implementation for WETH
}

contract MockFactory {
    address immutable public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address immutable public factory;
    address immutable public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract FeeManipulationTest is Test {
    MoonBoi token;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Create mock ecosystem
        address mockWETH = address(new MockWETH());
        address mockPair = makeAddr("mockPair");
        MockFactory mockFactory = new MockFactory(mockPair);
        MockRouter mockRouter = new MockRouter(
            address(mockFactory), 
            address(mockWETH)
        );
        
        // Overwrite PancakeRouter address with mock code
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Deploy token contract
        token = new MoonBoi();
    }
    
    function test_SetExcessiveFees() public {
        // Get initial tax rates
        console.log("--- BEFORE Trigger (Initial Taxes) ---");
        (
            uint256 burnTaxBefore,
            uint256 liquidityTaxBefore,
            uint256 stakingTaxBefore,
            uint256 buyTaxBefore,
            uint256 sellTaxBefore,
            uint256 transferTaxBefore
        ) = token.getTaxes();
        
        console.log("Initial buyTax:", buyTaxBefore);
        console.log("Initial sellTax:", sellTaxBefore);
        console.log("Initial transferTax:", transferTaxBefore);
        
        // Perform fee manipulation
        console.log("\n--- TRIGGER: Set Taxes to 26% ---");
        token.TeamSetTaxes(0, 0, 100, 26, 26, 26);
        
        // Verify tax changes
        console.log("\n--- AFTER Trigger (Verification) ---");
        (
            uint256 burnTax, 
            uint256 liquidityTax, 
            uint256 stakingTax,
            uint256 buyTax,
            uint256 sellTax,
            uint256 transferTax
        ) = token.getTaxes();
        
        console.log("Updated buyTax:", buyTax);
        console.log("Updated sellTax:", sellTax);
        console.log("Updated transferTax:", transferTax);
        
        // Check if any tax exceeds 25% threshold
        if (buyTax <= 25 && sellTax <= 25 && transferTax <= 25) {
            console.log("Vulnerability not Exist: All taxes at or below 25% limit");
        } else {
            console.log("Vulnerability Exists: Taxes successfully set above 25%");
        }
        
        // Original assertions
        assertEq(burnTax, 0, "Burn tax mismatch");
        assertEq(liquidityTax, 0, "Liquidity tax mismatch");
        assertEq(stakingTax, 100, "Staking tax mismatch");
        assertEq(buyTax, 26, "Buy tax not set to 26%");
        assertEq(sellTax, 26, "Sell tax not set to 26%");
        assertEq(transferTax, 26, "Transfer tax not set to 26%");
    }
}