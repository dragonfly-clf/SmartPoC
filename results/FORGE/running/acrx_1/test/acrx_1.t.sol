// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ACRUX.sol";

contract AcruxTest is Test {
    ACRUX public token;
    address payable public owner = payable(address(0x1));
    address payable public marketingWallet = payable(address(0x2));
    address payable public charityWallet = payable(address(0x3));
    
    // Mock addresses with valid checksums
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public mockFactory = 0xfAC7100000000000000000000000000000000000;
    address public mockWETH = 0xdEad000000000000000000000000000000000000;
    address public mockPair = 0xbeeF000000000000000000000000000000000000;

    function setUp() public {
        // Mock router and factory calls
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );

        // Deploy token as owner
        vm.startPrank(owner);
        token = new ACRUX(marketingWallet, charityWallet);
        vm.stopPrank();
    }

    function testTaxFeeManipulation() public {
        uint256 MAX_ACCEPTABLE_FEE = 25; // 25% maximum fee allowed by audit

        console.log("--- BEFORE-Trigger Fee Query ---");
        // Get tax fee before any changes (initial state)
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial tax fee (before any changes):", initialTaxFee);

        // Owner sets fee to 25% (should succeed)
        console.log("--- Trigger: Setting fee to MAX (25%) ---");
        vm.prank(owner);
        token.setTaxFeePercent(MAX_ACCEPTABLE_FEE);

        console.log("--- AFTER-Trigger 25% Fee Query ---");
        uint256 taxFeeAfter25 = token._taxFee();
        console.log("State after setting 25%:", taxFeeAfter25);

        // Owner sets fee to 26% (demonstrates vulnerability)
        uint256 excessFee = MAX_ACCEPTABLE_FEE + 1;
        console.log("--- Trigger: Setting fee to excess (26%) ---");
        vm.prank(owner);
        token.setTaxFeePercent(excessFee);

        console.log("--- AFTER-Trigger 26% Fee Query ---");
        uint256 finalTaxFee = token._taxFee();
        console.log("State after setting 26%:", finalTaxFee);

        // Differential validation
        console.log("--- DIFFERENTIAL VERDICT ---");
        bool vulnerabilityExists = finalTaxFee > MAX_ACCEPTABLE_FEE;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Tax fee successfully set above maximum allowed limit (25%)");
        } else {
            console.log("Vulnerability not Exist: Contract prevented tax fee from exceeding 25% limit");
        }
    }
}