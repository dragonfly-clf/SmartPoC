// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Play2Burn.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1234567890AbcdEF1234567890aBcdef12345678);
    }
}

contract MockRouter {
    address public factory;
    address public immutable weth;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract Play2BurnFeeTest is Test {
    Play2Burn public token;
    address public constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant DUMMY_WETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    MockFactory public mockFactory;
    MockRouter public mockRouter;
    
    function setUp() public {
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), DUMMY_WETH);
        
        // Mock the router contract at the real address
        vm.etch(REAL_ROUTER, address(mockRouter).code);
        vm.store(
            REAL_ROUTER,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            REAL_ROUTER,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(DUMMY_WETH)))
        );
        
        // Deploy token
        token = new Play2Burn();
    }

    function test_fee_manipulation_beyond_limit() public {
        address tokenOwner = token.owner();
        
        console2.log("--- BEFORE-Trigger Fee Values ---");
        // Record initial fee values
        (uint16 initLiqBuy, uint16 initMktBuy, uint16 initRewBuy, uint16 initTaxBuy) = token.buyFee();
        (uint16 initLiqSell, uint16 initMktSell, uint16 initRewSell, uint16 initTaxSell) = token.sellFee();
        console2.log("Initial Buy Fee: [liquidity=%d, marketing=%d, reward=%d, tax=%d]", 
            initLiqBuy, initMktBuy, initRewBuy, initTaxBuy);
        console2.log("Initial Sell Fee: [liquidity=%d, marketing=%d, reward=%d, tax=%d]", 
            initLiqSell, initMktSell, initRewSell, initTaxSell);

        console2.log("--- Trigger setBuyFee/setSellFee ---");
        // Owner sets buy fees to 100% (exceeding expected limit)
        vm.prank(tokenOwner);
        token.setBuyFee(100, 100, 100, 100);
        
        // Owner sets sell fees to 100% (exceeding expected limit)
        vm.prank(tokenOwner);
        token.setSellFee(100, 100, 100, 100);
        
        console2.log("--- AFTER-Trigger Fee Values ---");
        // Record new fee values after manipulation
        (uint16 newLiqBuy, uint16 newMktBuy, uint16 newRewBuy, uint16 newTaxBuy) = token.buyFee();
        (uint16 newLiqSell, uint16 newMktSell, uint16 newRewSell, uint16 newTaxSell) = token.sellFee();
        console2.log("New Buy Fee: [liquidity=%d, marketing=%d, reward=%d, tax=%d]", 
            newLiqBuy, newMktBuy, newRewBuy, newTaxBuy);
        console2.log("New Sell Fee: [liquidity=%d, marketing=%d, reward=%d, tax=%d]", 
            newLiqSell, newMktSell, newRewSell, newTaxSell);
        
        // Verify fees were set beyond acceptable limits
        bool buyFee100 = newLiqBuy == 100 && newMktBuy == 100 && newRewBuy == 100 && newTaxBuy == 100;
        bool sellFee100 = newLiqSell == 100 && newMktSell == 100 && newRewSell == 100 && newTaxSell == 100;
        
        // Final vulnerability verdict
        if (buyFee100 && sellFee100) {
            console2.log("Vulnerability Exists: Fees successfully set to 100%");
        } else {
            console2.log("Vulnerability not Exist: Fees not updated to 100%");
        }
    }
}