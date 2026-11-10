// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DARKMATTER.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract DARKMATTER_FeeManipulationTest is Test {
    DARKMATTER public token;
    address owner = makeAddr("owner");
    uint256 constant MAX_FEE = 25;
    
    function setUp() public {
        // Create mock dependencies
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(
            address(factory),
            address(0xC0fFee)
        );
        address busd = makeAddr("BUSD");
        
        // Deploy token contract
        vm.prank(owner);
        token = new DARKMATTER(address(router), busd);
    }
    
    function test_ownerCanSetExcessiveFees() public {
        uint256 taxFee = 15;
        uint256 liquidityFee = 15;
        uint256 marketingFee = 10;
        uint256 burnFee = 5;
        uint256 totalFee = taxFee + liquidityFee + marketingFee + burnFee;

        assertGt(totalFee, MAX_FEE, "Fees exceed recommended limit");
        
        // Capture initial fee state
        console.log("--- BEFORE-Trigger Fee Values ---");
        uint256 initialTaxFee = token._taxFee();
        uint256 initialLiquidityFee = token._liquidityFee();
        uint256 initialMarketingFee = token._marketingFee();
        uint256 initialBurnFee = token._burnFee();
        console.log("Initial _taxFee:", initialTaxFee);
        console.log("Initial _liquidityFee:", initialLiquidityFee);
        console.log("Initial _marketingFee:", initialMarketingFee);
        console.log("Initial _burnFee:", initialBurnFee);

        // Critical vulnerability trigger
        console.log("--- Trigger: setFees ---");
        vm.prank(owner);
        token.setFees(taxFee, liquidityFee, marketingFee, burnFee);
        
        // Capture new fee state
        console.log("--- AFTER-Trigger Fee Values ---");
        uint256 newTaxFee = token._taxFee();
        uint256 newLiquidityFee = token._liquidityFee();
        uint256 newMarketingFee = token._marketingFee();
        uint256 newBurnFee = token._burnFee();
        console.log("New _taxFee:", newTaxFee);
        console.log("New _liquidityFee:", newLiquidityFee);
        console.log("New _marketingFee:", newMarketingFee);
        console.log("New _burnFee:", newBurnFee);
        
        // Differential verification
        bool feesChanged = (newTaxFee != initialTaxFee) ||
            (newLiquidityFee != initialLiquidityFee) ||
            (newMarketingFee != initialMarketingFee) ||
            (newBurnFee != initialBurnFee);
            
        if (feesChanged) {
            console.log("Vulnerability Exists: Fee parameters successfully modified by owner");
        } else {
            console.log("Vulnerability not Exist: Fee parameters unchanged after setFees");
        }
        
        // Verify non-owner cannot change fees (doesn't produce logs)
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setFees(99, 1, 0, 0);
    }
}