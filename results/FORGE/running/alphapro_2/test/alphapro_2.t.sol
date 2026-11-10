// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AlphaProtocol.sol";

contract MockPair {}

contract AlphaTransferTaxTest is Test {
    AlphaProtocol token;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant TREASURY_RECEIVER = 0x7c1a586f27423d021DF0cCbE306Db5f222fff55e;

    function setUp() public {
        // Deploy mock pair contract
        MockPair mockPair = new MockPair();
        address pairAddress = address(mockPair);
        
        // Define WETH address
        address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        
        // Define arbitrary factory address
        address factory = address(0x1234567890123456789012345678901234567890);
        
        // Mock router calls
        bytes4 factorySelector = bytes4(keccak256("factory()"));
        vm.mockCall(
            ROUTER,
            abi.encodePacked(factorySelector),
            abi.encode(factory)
        );
        
        bytes4 wethSelector = bytes4(keccak256("WETH()"));
        vm.mockCall(
            ROUTER,
            abi.encodePacked(wethSelector),
            abi.encode(WETH)
        );
        
        // Mock factory pair creation
        bytes4 createPairSelector = bytes4(
            keccak256("createPair(address,address)")
        );
        vm.mockCall(
            factory,
            abi.encodePacked(createPairSelector),
            abi.encode(pairAddress)
        );
        
        // Mock pair sync call
        bytes4 syncSelector = bytes4(keccak256("sync()"));
        vm.mockCall(
            pairAddress,
            abi.encodePacked(syncSelector),
            abi.encode()
        );
        
        // Deploy token contract after mocks are setup
        token = new AlphaProtocol();
    }

    function testTransferTaxManipulation() public {
        console.log("--- BEFORE-Trigger transferTax ---");
        uint256 taxBefore = token.transferTax();
        console.log("Transfer tax before: %s", taxBefore);

        console.log("--- Trigger: setTransferTax(5000) ---");
        vm.prank(TREASURY_RECEIVER);
        token.setTransferTax(5000);

        console.log("--- AFTER-Trigger transferTax ---");
        uint256 taxAfter = token.transferTax();
        console.log("Transfer tax after: %s", taxAfter);

        // Verify tax changed to 5000 (50%)
        bool taxChanged = (taxAfter == 5000);
        console.log("State changed: %s", taxChanged ? "YES" : "NO");
        console.log("Exploit successful: %s", taxChanged ? "YES" : "NO");

        // Additional revert test
        vm.startPrank(TREASURY_RECEIVER);
        vm.expectRevert("AlphaPro: Maximum Transfer Tax Is 50%");
        token.setTransferTax(5001);
        vm.stopPrank();

        // Final verdict based on state change
        if (taxChanged) {
            console.log("Vulnerability Exists: Owner successfully changed transfer tax to 50%");
        } else {
            console.log("Vulnerability not Exist: Transfer tax remains at pre-attack value");
        }
    }
}