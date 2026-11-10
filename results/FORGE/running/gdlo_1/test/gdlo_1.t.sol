// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeloanGovernanceToken.sol";

contract FeeManipulationTest is Test {
    DeloanGovernanceToken token;
    address constant owner = 0x23Fa43d0A5Ea9917A871F7542D2ca10877338f4B;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDR = address(uint160(0xFAC70)); // Cast integer to address
    address constant WETH_ADDR = address(uint160(0xBEEF));    // Cast integer to address
    address constant DUMMY_PAIR = address(uint160(0xDEAD));  // Cast integer to address

    function setUp() public {
        // Mock router's factory() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(FACTORY_ADDR)
        );
        
        // Mock router's WETH() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(WETH_ADDR)
        );
        
        // Mock factory's createPair call
        vm.mockCall(
            FACTORY_ADDR,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(DUMMY_PAIR)
        );

        // Deploy token as owner
        vm.startPrank(owner);
        token = new DeloanGovernanceToken();
        vm.stopPrank();
    }

    function testTaxFeeExceedsLimit() public {
        uint256 EXCEEDING_FEE = 26; // Above 25% limit

        console.log("--- BEFORE-Trigger Fee Setting ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preDevFee = token._developmentFee();
        console.log("preTaxFee:", preTaxFee);
        console.log("preDevFee:", preDevFee);

        console.log("--- Trigger setTaxFeePercent(26) ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(EXCEEDING_FEE);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee Setting ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postDevFee = token._developmentFee();
        console.log("postTaxFee:", postTaxFee);
        console.log("postDevFee:", postDevFee);

        if (postTaxFee > 25) {
            console.log("Vulnerability Exists: Tax fee exceeds 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee within allowed limits");
        }
    }
    
    function testCombinedFeesExceedLimit() public {
        console.log("--- BEFORE-Trigger Combined Fee Setting ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preDevFee = token._developmentFee();
        uint256 preTotalFees = preTaxFee + preDevFee;
        console.log("preTaxFee:", preTaxFee);
        console.log("preDevFee:", preDevFee);
        console.log("preTotalFees:", preTotalFees);

        console.log("--- Trigger setTaxFeePercent(15) + setDevelopmentFeePercent(11) ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(15);
        token.setDevelopmentFeePercent(11);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee Setting ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postDevFee = token._developmentFee();
        uint256 postTotalFees = postTaxFee + postDevFee;
        console.log("postTaxFee:", postTaxFee);
        console.log("postDevFee:", postDevFee);
        console.log("postTotalFees:", postTotalFees);

        if (postTotalFees > 25) {
            console.log("Vulnerability Exists: Combined fees exceed 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Combined fees within allowed limits");
        }
    }
}