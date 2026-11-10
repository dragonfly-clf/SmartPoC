// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract WETH {
    function deposit() external payable {}
    function withdraw(uint256) external {}
    function approve(address, uint256) external returns (bool) {}
    function transfer(address, uint256) external returns (bool) {}
}

contract MockFactory {
    address public PAIR_ADDRESS;
    
    constructor() {
        PAIR_ADDRESS = address(0xdead);
    }
    
    function createPair(address, address) external returns (address) {
        return PAIR_ADDRESS;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract TokenToolTest is Test {
    TokenTool token;
    
    address owner = address(0x1);
    address marketing = address(0x3);
    address team = address(0x4);
    address service = address(0x5);
    uint256 supply = 1000000 * 10**18;
    
    MockFactory mockFactory;
    MockRouter mockRouter;
    WETH mockWETH;

    function setUp() public {
        // Deploy mock contracts
        mockWETH = new WETH();
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Fund owner
        vm.deal(owner, 10 ether);
        
        vm.startPrank(owner);
        token = new TokenTool{value: 1 ether}(
            "TestToken",
            "TEST",
            18,
            supply,
            address(mockRouter),
            owner,
            marketing,
            team,
            service
        );
        vm.stopPrank();
    }

    function test_SellTaxExceedsLimit() public {
        console.log("--- BEFORE-Trigger: Sell Tax State ---");
        uint256 liqBefore = token._sellLiquidityFee();
        uint256 marketingBefore = token._sellMarketingFee();
        uint256 teamBefore = token._sellTeamFee();
        uint256 totalTaxBefore = token._totalTaxIfSelling();
        uint256 computedTotalBefore = liqBefore + marketingBefore + teamBefore;
        
        console.log("Liquidity fee:", liqBefore, "%");
        console.log("Marketing fee:", marketingBefore, "%");
        console.log("Team fee:", teamBefore, "%");
        console.log("Total tax (function):", totalTaxBefore, "%");
        console.log("Computed total:", computedTotalBefore, "%");

        // Trigger action
        console.log("--- TRIGGER: Call setSelTaxes(30,30,30) ---");
        bool success;
        string memory verdict;
        vm.startPrank(owner);
        try token.setSelTaxes(30,30,30) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();
        
        if (!success) {
            console.log("Result: Transaction reverted");
            verdict = "Vulnerability not Exist: Transaction reverted as expected for excessive taxes";
        } else {
            // AFTER: Query tax state again
            console.log("--- AFTER-Trigger: Sell Tax State ---");
            uint256 liqAfter = token._sellLiquidityFee();
            uint256 marketingAfter = token._sellMarketingFee();
            uint256 teamAfter = token._sellTeamFee();
            uint256 totalTaxAfter = token._totalTaxIfSelling();
            uint256 computedTotalAfter = liqAfter + marketingAfter + teamAfter;

            console.log("Liquidity fee:", liqAfter, "%");
            console.log("Marketing fee:", marketingAfter, "%");
            console.log("Team fee:", teamAfter, "%");
            console.log("Total tax (function):", totalTaxAfter, "%");
            console.log("Computed total:", computedTotalAfter, "%");
            
            // Verify tax rates were set to expected values
            if (liqAfter == 30 && marketingAfter == 30 && teamAfter == 30) {
                verdict = "Vulnerability Exists: Total sell tax set to 90%, far exceeding acceptable limit";
            } else {
                verdict = "Vulnerability not Exist: Tax rates not updated to requested values";
            }
        }
        
        // Final verdict output
        console.log(verdict);
    }
}