// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PULIINU.sol";

interface IPULIINU {
    struct FeeData {
        uint16 liquidityFee;
        uint16 marketingFee;
        uint16 buybackFee;
        uint16 taxFee;
    }
    
    function buyFee() external view returns (FeeData memory);
    function setBuyFee(uint16, uint16, uint16, uint16) external;
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract PULIFeeManipulationTest is Test {
    IPULIINU public token;
    address owner = address(0x1);
    address payable marketingWallet = payable(address(0x9));
    address constant ROUTER_ADDR = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        // Deploy mock factory and router
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory));

        // Override real router address with mock code
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        // Store mock factory address in router's storage
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = IPULIINU(address(new PULIINU(
            0,      // deadBlocks
            50,     // buyliq 
            50,     // buymarket 
            100,    // sellliq 
            100,    // sellmarket
            marketingWallet,
            1000e18, // supply
            1e18,    // numTokens
            100e18,  // maxWallet
            10e18,   // maxBuy
            10e18    // maxSell
        )));
        vm.stopPrank();
    }

    function test_OwnerCanSetArbitraryFees() public {
        console.log("--- BEFORE-Trigger Buy Fee ---");
        // Get initial fee structure via public getter
        IPULIINU.FeeData memory initialFee = token.buyFee();
        console.log("Initial liquidity fee:", initialFee.liquidityFee);
        console.log("Initial marketing fee:", initialFee.marketingFee);
        console.log("Initial buyback fee:", initialFee.buybackFee);
        console.log("Initial tax fee:", initialFee.taxFee);

        console.log("--- Trigger setBuyFee(10000, 10000, 0, 0) ---");
        // Set fees to 100% each (10000 basis points = 100%)
        vm.prank(owner);
        token.setBuyFee(10000, 10000, 0, 0);

        console.log("--- AFTER-Trigger Buy Fee ---");
        // Get new fee structure after modification
        IPULIINU.FeeData memory updatedFee = token.buyFee();
        console.log("Updated liquidity fee:", updatedFee.liquidityFee);
        console.log("Updated marketing fee:", updatedFee.marketingFee);
        console.log("Updated buyback fee:", updatedFee.buybackFee);
        console.log("Updated tax fee:", updatedFee.taxFee);

        // Verify fee changes using differential comparison
        bool liquidityFeeChanged = initialFee.liquidityFee != updatedFee.liquidityFee;
        bool marketingFeeChanged = initialFee.marketingFee != updatedFee.marketingFee;
        bool feesSetToMax = updatedFee.liquidityFee == 10000 && 
                            updatedFee.marketingFee == 10000;

        console.log("Liquidity fee changed:", liquidityFeeChanged);
        console.log("Marketing fee changed:", marketingFeeChanged);
        console.log("Fees set to 100%:", feesSetToMax);

        // Final vulnerability verification
        if (feesSetToMax) {
            console.log("Vulnerability Exists: Owner can set fees to 100%");
        } else {
            console.log("Vulnerability not Exist: Fee limitation works as expected");
        }
    }
}