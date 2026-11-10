// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PULIINU.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract PULIINUFeeTest is Test {
    PULIINU token;
    address deployer = address(0x1);
    address payable marketing = payable(address(0x2));
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        address fakeWETH = address(0x123);
        address mockFactory = address(new MockUniswapV2Factory());
        address mockRouter = address(new MockUniswapV2Router(mockFactory, fakeWETH));
        
        // Mock router at real address
        vm.etch(ROUTER_ADDR, mockRouter.code);

        // Deploy token with safe parameters
        vm.prank(deployer);
        token = new PULIINU(
            0,               // _deadBlocks
            1,               // _buyliq
            1,               // _buymarket
            1,               // _sellliq
            1,               // _sellmarket
            marketing,       // _marketing
            1_000_000,       // _supply
            500,             // _numTokens
            10_000,          // _maxWallet
            10_000,          // _maxBuy
            10_000           // _maxSell
        );
    }

    function test_FeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger fee state: ---");
        // Deconstruct tuple into individual components
        (uint16 liqBefore, uint16 marketBefore, uint16 buybackBefore, uint16 taxBefore) = token.sellFee();
        console.log("liquidityFee: %s", liqBefore);
        console.log("marketingFee: %s", marketBefore);
        console.log("buybackFee: %s", buybackBefore);
        console.log("taxFee: %s", taxBefore);

        console.log("--- Trigger: setSellFee(10000,10000,10000,10000) ---");
        vm.prank(deployer);
        token.setSellFee(10000, 10000, 10000, 10000);
        
        console.log("--- AFTER-Trigger fee state: ---");
        // Deconstruct tuple after modification
        (uint16 liqAfter, uint16 marketAfter, uint16 buybackAfter, uint16 taxAfter) = token.sellFee();
        console.log("liquidityFee: %s", liqAfter);
        console.log("marketingFee: %s", marketAfter);
        console.log("buybackFee: %s", buybackAfter);
        console.log("taxFee: %s", taxAfter);

        // Check if all fees were set to 10000
        bool vulnerabilityExists = (
            liqAfter == 10000 &&
            marketAfter == 10000 &&
            buybackAfter == 10000 &&
            taxAfter == 10000
        );

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees successfully set to 100%% total");
        } else {
            console.log("Vulnerability not Exist: Fee values not set to 10000");
        }
    }
}