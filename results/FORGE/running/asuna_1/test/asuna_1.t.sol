// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AsunaHentai.sol";

contract AsunaHentaiFeeTest is Test {
    AsunaHentai token;
    address owner = address(0x1);
    address user = address(0x2);
    
    // Mock contract addresses setup
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0x123);
    address constant MOCK_PAIR = address(0x456);
    address constant WETH_ADDRESS = address(0x789);

    function setUp() public {
        // Setup router mocks
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Setup factory mock to accept any createPair call using selector matching
        bytes4 createPairSelector = bytes4(keccak256(bytes("createPair(address,address)")));
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodePacked(createPairSelector),
            abi.encode(MOCK_PAIR)
        );

        // Deploy contract
        vm.startPrank(owner);
        token = new AsunaHentai();
        vm.stopPrank();
    }

    function test_OwnerCanSetExcessiveFees() public {
        console.log("--- BEFORE-Trigger Fee Values ---");
        // Query initial fee values
        uint256 preBuyFee = token._buyAdvestisementFee();
        uint256 preSellFee = token._sellAdvestisementFee();
        console.log("Initial buy fee:", preBuyFee);
        console.log("Initial sell fee:", preSellFee);
        console.log("---------------------------");

        console.log("--- Trigger: setAdvestisementFeePercent(26,26) ---");
        // Owner sets new fee values (26%) exceeding 25% threshold
        uint256 newBuyFee = 26;
        uint256 newSellFee = 26;
        vm.prank(owner);
        token.setAdvestisementFeePercent(newBuyFee, newSellFee);

        console.log("--- AFTER-Trigger Fee Values ---");
        // Query fee values after manipulation
        uint256 postBuyFee = token._buyAdvestisementFee();
        uint256 postSellFee = token._sellAdvestisementFee();
        console.log("Updated buy fee:", postBuyFee);
        console.log("Updated sell fee:", postSellFee);
        console.log("---------------------------");

        // Evaluate vulnerability conditions: both thresholds must be exceeded
        bool buyExceeded = (postBuyFee > 25);
        bool sellExceeded = (postSellFee > 25);
        bool vulnerable = buyExceeded && sellExceeded;

        // Print final verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: Both fees exceed 25% limit after owner manipulation");
        } else {
            console.log("Vulnerability not Exist: Fees remain within 25% limit constraints");
        }

        // Maintain original assertions
        assertEq(postBuyFee, newBuyFee, "Buy fee not updated");
        assertEq(postSellFee, newSellFee, "Sell fee not updated");
        assertTrue(newBuyFee > 25, "Buy fee exceeds 25% limit");
        assertTrue(newSellFee > 25, "Sell fee exceeds 25% limit");
    }

    function test_NonOwnerCannotSetFees() public {
        // Attempt to set fees as non-owner
        vm.startPrank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setAdvestisementFeePercent(20, 20);
        vm.stopPrank();
    }
}