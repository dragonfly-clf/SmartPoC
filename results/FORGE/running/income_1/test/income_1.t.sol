// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/INCOME.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
    function transfer(address, uint) external returns (bool) {}
}

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    MockPair public pair;

    constructor() {
        pair = new MockPair();
    }

    function createPair(address, address) external view returns (address) {
        return address(pair);
    }
}

contract MockRouter {
    MockFactory public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = MockFactory(_factory);
        WETH = _weth;
    }
}

contract INCOME_FeeTest is Test {
    INCOME token;
    uint256 public constant MAX_TOTAL_FEES = 25; // 25% limit
    address constant REAL_ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock WETH
        MockWETH mockWETH = new MockWETH();
        
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Replace real router with mock
        vm.etch(REAL_ROUTER_ADDR, address(mockRouter).code);
        
        // Deploy main token contract
        token = new INCOME();
    }

    function testFeeManipulationVulnerability() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Record initial fee parameters
        uint initialBNBFee = token.BNBRewardsFee();
        uint initialLiqFee = token.liquidityFee();
        uint initialMktFee = token.marketingFee();
        uint initialTotal = token.totalFees();
        
        console.log("Initial BNB Fee:", initialBNBFee);
        console.log("Initial Liquidity Fee:", initialLiqFee);
        console.log("Initial Marketing Fee:", initialMktFee);
        console.log("Initial Total Fees:", initialTotal);

        console.log("--- Trigger setFee (Vulnerable Operation) ---");
        // Define excessive fees (10% each)
        uint256 _bnbFee = 10;
        uint256 _liquidityFee = 10;
        uint256 _marketingFee = 10;
        uint256 totalFees = _bnbFee + _liquidityFee + _marketingFee; // 30%
        
        // Ensure test configuration is correct
        assert(totalFees > MAX_TOTAL_FEES);

        // Owner sets fees exceeding the 25% limit
        vm.prank(token.owner());
        token.setFee(_bnbFee, _liquidityFee, _marketingFee);

        console.log("--- AFTER-Trigger Fee State ---");
        // Read state variables after attack
        uint256 bnbFeeActual = token.BNBRewardsFee();
        uint256 liquidityFeeActual = token.liquidityFee();
        uint256 marketingFeeActual = token.marketingFee();
        uint256 totalFeesActual = token.totalFees();

        console.log("New BNB Fee:", bnbFeeActual);
        console.log("New Liquidity Fee:", liquidityFeeActual);
        console.log("New Marketing Fee:", marketingFeeActual);
        console.log("New Total Fees:", totalFeesActual);

        // Differential results
        console.log("=== DIFFERENTIAL VERDICT ===");
        bool feeChanged = (initialBNBFee != bnbFeeActual) || 
                          (initialLiqFee != liquidityFeeActual) || 
                          (initialMktFee != marketingFeeActual);
        
        bool limitExceeded = totalFeesActual > MAX_TOTAL_FEES;
        
        console.log("Change detected in fees:", feeChanged ? "YES" : "NO");
        console.log("Total fees exceed 25% limit:", limitExceeded ? "YES" : "NO");

        // Final vulnerability verdict
        if(feeChanged && limitExceeded) {
            console.log("RESULT: Vulnerability Exists - Fees were changed to exceed 25% limit");
        } else if(feeChanged) {
            console.log("RESULT: Vulnerability not Exist - Fees changed but total within 25% limit");
        } else {
            console.log("RESULT: Vulnerability not Exist - Fee parameters unchanged");
        }
    }
}