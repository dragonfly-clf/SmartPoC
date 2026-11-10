// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockWETH {
    // Simple mock for WETH
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabcd);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;

    constructor(address _weth) {
        factory = address(new MockFactory());
        WETH = _weth;
    }
}

contract CoinTokenFeeTest is Test {
    CoinToken token;
    address owner;
    address service = address(0x123);
    MockRouter router;
    address weth = address(new MockWETH());

    function setUp() public {
        owner = address(this); // Make test contract the owner
        vm.deal(owner, 10 ether); // Fund the owner
        
        router = new MockRouter(weth);
        
        token = new CoinToken{value: 1 ether}(
            "Test Token",
            "TEST",
            18,
            100000000 * 10**18, // supply
            1, // initial _txFee
            1, // initial _lpFee
            1, // initial _DexFee
            address(router), // valid router address
            address(0x2), // feeaddress
            owner, // tokenOwner
            service // service address
        );
    }

    function testTaxFeeCanBypass25PercentLimit() public {
        console.log("--- BEFORE-Trigger FeeQuery ---");
        // Query tax fee before manipulation
        uint256 preTaxFee = token._taxFee();
        console.log("Pre-attack tax fee: %s%%", preTaxFee);

        console.log("--- Trigger setTaxFeePercent(30) ---");
        // Attempt to set tax fee beyond 25% limit
        uint256 excessiveFee = 30;
        token.setTaxFeePercent(excessiveFee);
        
        console.log("--- AFTER-Trigger FeeQuery ---");
        // Query tax fee after manipulation
        uint256 postTaxFee = token._taxFee();
        console.log("Post-attack tax fee: %s%%", postTaxFee);

        // Vulnerability determination logic
        if (postTaxFee > 25) {
            console.log("Vulnerability Exists: Tax fee successfully set to %s%%, bypassing 25%% limit", postTaxFee);
        } else {
            console.log("Vulnerability not Exist: Tax fee remains %s%% (within 25%% limit)", postTaxFee);
        }
    }
}