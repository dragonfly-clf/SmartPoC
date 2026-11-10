// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SINCEREBAT.sol";

contract SINCEREBATFeeTest is Test {
    address constant UNISWAP_V2_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    SincereBatMockWETH mockWETH;
    SincereBatMockFactory mockFactory;
    SincereBatMockRouter mockRouter;
    address mockPair;
    
    SINCEREBAT token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        // Deploy mock contracts
        mockWETH = new SincereBatMockWETH();
        mockFactory = new SincereBatMockFactory();
        mockPair = makeAddr("mockPair");
        mockFactory.setPair(mockPair);
        mockRouter = new SincereBatMockRouter(address(mockFactory), address(mockWETH));
        
        // Setup Uniswap mock at hardcoded address
        vm.etch(UNISWAP_V2_ROUTER_ADDRESS, address(mockRouter).code);

        vm.prank(owner);
        token = new SINCEREBAT();
    }

    function test_FeeExceeds25PercentLimit() public {
        uint256 decimals = token.decimals();
        uint256 amountToTransfer = 100 * 10 ** decimals;

        // Configure token settings
        vm.startPrank(owner);
        token.excludeFromReward(alice);
        token.excludeFromReward(bob);
        token.setSwapAndLiquifyEnabled(false);
        token.setTaxFeePercent(7);
        token.setLiquidityFeePercent(7);
        token.setdeveloperFeePercent(7);
        token.setcharityFeePercent(7);
        token.transfer(alice, amountToTransfer);
        vm.stopPrank();

        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Bob initial balance: ", token.balanceOf(bob));
        console.log("Transfer amount: ", amountToTransfer);
        
        console.log("--- Trigger Transfer ---");
        uint256 bobBefore = token.balanceOf(bob);
        vm.prank(alice);
        token.transfer(bob, amountToTransfer);
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 bobAfter = token.balanceOf(bob);
        console.log("Bob balance after transfer: ", bobAfter);

        // Calculate fee deduction details
        uint256 receivedAmt = bobAfter - bobBefore;
        uint256 feeDeduction = amountToTransfer - receivedAmt;
        uint256 feePercentage = (feeDeduction * 100) / amountToTransfer;
        
        console.log("Actual received amount: ", receivedAmt);
        console.log("Fee deducted: ", feeDeduction);
        console.log("Fee percentage: ", feePercentage, "%");
        
        // Final vulnerability verification
        if(feePercentage > 25) {
            console.log("Vulnerability Exists: Total fee exceeds 25% limit (actual fee: ", feePercentage, "%)");
        } else {
            console.log("Vulnerability not Exist: Total fee within 25% limit (actual fee: ", feePercentage, "%)");
        }

        // Original assertion to validate test result
        assertGt(feePercentage, 25, "Tax fee exceeds 25% limit");
    }
}

// Mock contracts - renamed to avoid naming conflicts
contract SincereBatMockWETH {}

contract SincereBatMockFactory {
    address public pair;

    function setPair(address _pair) public {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract SincereBatMockRouter {
    address private immutable _factory;
    address private immutable _weth;

    constructor(address __factory, address __weth) {
        _factory = __factory;
        _weth = __weth;
    }

    function factory() external view returns (address) {
        return _factory;
    }

    function WETH() external view returns (address) {
        return _weth;
    }
}