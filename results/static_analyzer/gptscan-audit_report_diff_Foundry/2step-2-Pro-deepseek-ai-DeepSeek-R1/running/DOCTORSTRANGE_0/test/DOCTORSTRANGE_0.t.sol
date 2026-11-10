// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOCTORSTRANGE.sol";

contract DoctorStrangeTest is Test {
    DOCTORSTRANGE token;
    // Addresses
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    // Mock addresses
    address constant MOCK_FACTORY = address(0xA);
    address constant MOCK_PAIR = address(0xB);

    function setUp() public {
        // Mock the router's factory() call to return MOCK_FACTORY
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IDEXRouter.factory.selector),
            abi.encode(MOCK_FACTORY)
        );

        // Mock the factory's createPair() call with any arguments
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(IDEXFactory.createPair.selector),
            abi.encode(MOCK_PAIR)
        );

        // Deploy the token contract
        token = new DOCTORSTRANGE();
    }

    function test_BuybackUsesVulnerableSwapFunction() public {
        uint256 amount = 1 ether;
        // Fund the token contract with Ether
        vm.deal(address(token), amount);

        // Prepare the expected path
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(token);

        console.log("--- BEFORE-Trigger State ---");
        console.log("No observable state change for differential validation");
        
        console.log("--- Trigger Function Call ---");
        // Verify call to router with parameters that trigger vulnerability
        vm.expectCall(
            ROUTER_ADDRESS,
            amount, // value sent
            abi.encodeWithSelector(
                IDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens.selector,
                0,
                path,
                DEAD,
                block.timestamp
            )
        );

        // Trigger the vulnerable function
        token.triggerManualBuyback(amount, false);
        console.log("Manual buyback triggered");
        
        console.log("--- AFTER-Trigger State ---");
        console.log("No observable state change for differential validation");

        console.log("Vulnerability Exists: The token's triggerManualBuyback function uses swapExactETHForTokensSupportingFeeOnTransferTokens which is vulnerable to sandwich attacks");
    }
}