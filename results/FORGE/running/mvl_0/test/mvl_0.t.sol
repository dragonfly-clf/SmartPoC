// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AntiBotLiquidityGeneratorToken.sol";

// Minimal mock implementations
contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xabcd);
    }
}

contract MockRouter {
    address private immutable _factory;
    address private immutable _weth;

    constructor(address factory_, address weth_) {
        _factory = factory_;
        _weth = weth_;
    }

    function factory() external view returns (address) {
        return _factory;
    }

    function WETH() external view returns (address) {
        return _weth;
    }
}

contract MockPinkAntiBot {
    function setTokenOwner(address) external {}
}

contract FeeManipulationTest is Test {
    AntiBotLiquidityGeneratorToken token;
    address owner = address(0x1);
    address charity = address(0x2);
    address feeReceiver = address(0x4);

    function setUp() public {
        // Deploy mock dependencies
        MockFactory factory = new MockFactory();
        MockPinkAntiBot pab = new MockPinkAntiBot();
        MockRouter router = new MockRouter(address(factory), address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        
        // Create token with proper initialization using owner profile
        vm.startPrank(owner);
        token = new AntiBotLiquidityGeneratorToken{value: 0}(
            "TestToken", 
            "TKN", 
            1_000_000 * 10**9,    // totalSupply_
            address(router),       // router_
            charity,               // charityAddress_
            0,                     // taxFeeBps_
            0,                     // liquidityFeeBps_
            0,                     // charityFeeBps_
            address(pab),          // pinkAntiBot_
            feeReceiver,           // serviceFeeReceiver_
            0                      // serviceFee_
        );
        vm.stopPrank();
    }

    function test_OwenCanSetUnlimitedTaxFee() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Pre-validation: Fee setting transaction not yet attempted");

        console.log("--- Trigger Fee Change ---");
        console.log("Attempting to set tax fee to 26% (2600 bps)...");
        bool success;
        bytes memory data;
        
        vm.startPrank(owner);
        (success, data) = address(token).call(
            abi.encodeWithSignature("setTaxFeePercent(uint256)", 2600)
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        console.log("Transaction status:", success ? "Success (no revert)" : "Reverted");
        
        if (success) {
            console.log("Vulnerability Exists: Owner successfully bypassed 25% fee limit restriction");
        } else {
            console.log("Vulnerability not Exist: Fee setting mechanism rejected the invalid fee value");
        }
    }
}