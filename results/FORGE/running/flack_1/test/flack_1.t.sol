// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Flack.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract FlackFeeTest is Test {
    Flack public token;
    MockFactory public mockFactory;
    MockRouter public mockRouter;
    
    function setUp() public {
        // Prepare router and deployment environment
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        
        // Set mock router code at Uniswap V2 address
        vm.etch(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(mockRouter).code);
        
        // Deploy token contract
        token = new Flack();
    }

    function test_SetFeeAbove25Percent() public {
        console2.log("--- BEFORE-Trigger getFees ---");
        uint256 buyFeeBefore = token.buyFee();
        uint256 sellFeeBefore = token.sellFee();
        console2.log("Initial buyFee (bps):", buyFeeBefore);
        console2.log("Initial sellFee (bps):", sellFeeBefore);

        console2.log("--- Trigger setFee(2600,2600) ---");
        // Set fees to 26% (denoted as 2600 basis points)
        // This exceeds the intended 25% limit and should succeed without validation
        token.setFee(2600, 2600);
        
        console2.log("--- AFTER-Trigger getFees ---");
        uint256 buyFeeAfter = token.buyFee();
        uint256 sellFeeAfter = token.sellFee();
        console2.log("Post-attack buyFee (bps):", buyFeeAfter);
        console2.log("Post-attack sellFee (bps):", sellFeeAfter);

        // Vulnerability exists if both fees were actually set to 2600
        if (buyFeeAfter == 2600 && sellFeeAfter == 2600) {
            console2.log("Vulnerability EXISTS: Fees were illegally increased to 26%");
            console2.log("Vulnerability Exists: Attack successfully set fees to 26% (exceeds 25% limit)");
        } else {
            console2.log("Vulnerability NOT EXISTS: Fee limit enforcement is working");
            console2.log("Vulnerability not Exist: Contract enforced 25% fee limit");
        }
    }
}