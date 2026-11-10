// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract MockFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address, address) external returns (address pair) {
        pair = address(0x1111111111111111111111111111111111111111);
        emit PairCreated(address(0), address(0), pair, 1);
        return pair;
    }
}

contract MinimalRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract APTDFeeTest is Test {
    APTD public aptd;
    MockFactory public mockFactory;
    address constant DEPLOYER = 0x22ba8aAb4c60Ac95e61CFC41dF8d2675aeb87C0b;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy mock contracts
        mockFactory = new MockFactory();
        MinimalRouter minimalRouter = new MinimalRouter(address(mockFactory));
        
        // Patch the Pancake Router address
        vm.etch(PANCAKE_ROUTER, address(minimalRouter).code);
        vm.store(
            PANCAKE_ROUTER,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        
        // Impersonate deployer and deploy APTD
        vm.startPrank(DEPLOYER);
        aptd = new APTD();
        vm.stopPrank();
    }

    function testOwnerCanSetFeesTo80Percent() public {
        // Pre-state inspection
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 buyFeesBefore = aptd.buyTotalFees();
        uint256 sellFeesBefore = aptd.sellTotalFees();
        console.log("Initial buyTotalFees:", buyFeesBefore);
        console.log("Initial sellTotalFees:", sellFeesBefore);

        // Attack execution
        console.log("--- Trigger updateFees (79+1=80) ---");
        vm.startPrank(DEPLOYER);
        aptd.updateBuyFees(79, 1);
        aptd.updateSellFees(79, 1);
        vm.stopPrank();

        // Post-state inspection
        console.log("--- AFTER-Trigger Fees ---");
        uint256 buyFeesAfter = aptd.buyTotalFees();
        uint256 sellFeesAfter = aptd.sellTotalFees();
        console.log("Updated buyTotalFees:", buyFeesAfter);
        console.log("Updated sellTotalFees:", sellFeesAfter);

        // Differential validation
        bool feesChanged = 
            (buyFeesAfter != buyFeesBefore) || 
            (sellFeesAfter != sellFeesBefore);
        bool vulnerableState = 
            (buyFeesAfter == 80) && 
            (sellFeesAfter == 80);
        
        console.log("Fees changed:", feesChanged ? "YES" : "NO");
        console.log("Fees set to 80%:", vulnerableState ? "YES" : "NO");
        
        if (vulnerableState) {
            console.log("Vulnerability Exists: Fees changed to 80%");
        } else {
            console.log("Vulnerability not Exist: Fees not set to 80%");
        }
    }

    function testOwnerCanSetFeesTo100Percent() public {
        // Pre-state inspection
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 buyFeesBefore = aptd.buyTotalFees();
        uint256 sellFeesBefore = aptd.sellTotalFees();
        console.log("Initial buyTotalFees:", buyFeesBefore);
        console.log("Initial sellTotalFees:", sellFeesBefore);

        // Attack execution
        console.log("--- Trigger updateFees (99+1=100) ---");
        vm.startPrank(DEPLOYER);
        aptd.updateBuyFees(99, 1);
        aptd.updateSellFees(99, 1);
        vm.stopPrank();

        // Post-state inspection
        console.log("--- AFTER-Trigger Fees ---");
        uint256 buyFeesAfter = aptd.buyTotalFees();
        uint256 sellFeesAfter = aptd.sellTotalFees();
        console.log("Updated buyTotalFees:", buyFeesAfter);
        console.log("Updated sellTotalFees:", sellFeesAfter);

        // Differential validation
        bool feesChanged = 
            (buyFeesAfter != buyFeesBefore) || 
            (sellFeesAfter != sellFeesBefore);
        bool vulnerableState = 
            (buyFeesAfter == 100) && 
            (sellFeesAfter == 100);
        
        console.log("Fees changed:", feesChanged ? "YES" : "NO");
        console.log("Fees set to 100%:", vulnerableState ? "YES" : "NO");
        
        if (vulnerableState) {
            console.log("Vulnerability Exists: Fees changed to 100%");
        } else {
            console.log("Vulnerability not Exist: Fees not set to 100%");
        }
    }
}