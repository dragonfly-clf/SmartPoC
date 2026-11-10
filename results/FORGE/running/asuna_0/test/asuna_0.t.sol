// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AsunaHentai.sol";

contract AntibotModeTest is Test {
    AsunaHentai token;
    address owner = address(this);
    address userA = address(0x1);
    address userB = address(0x2);
    uint256 initialSupply;
    
    function setUp() public {
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x02);
        address mockWETH = address(0x03);
        address mockPair = address(0x04);

        // Mock router calls
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new AsunaHentai();
        initialSupply = token.totalSupply();
        
        // Configure token settings
        token.setMaxTxPercent(100);
        token.setTaxFeePercent(0, 0);
        token.setAdvestisementFeePercent(0, 0);
        token.transfer(userA, initialSupply / 2);
        vm.stopPrank();
    }

    function testAntibotModeBlocksTransfers() public {
        console.log("--- BEFORE-Trigger Action ---");
        console.log("Antibot mode status: Off");
        console.log("UserA balance: %s", token.balanceOf(userA));
        console.log("UserB balance: %s", token.balanceOf(userB));
        
        console.log("--- Trigger Action: Turn on antibot mode ---");
        // Enable antibot mode
        vm.prank(owner);
        token.turnOnAntibotMode();

        console.log("--- AFTER-Trigger Action ---");
        console.log("Antibot mode status: On");
        uint256 transferAmount = token.balanceOf(userA) / 10;
        console.log("Attempting transfer: %s from UserA to UserB", transferAmount);

        // Attempt transfer between non-whitelisted users
        vm.startPrank(userA);        
        vm.expectRevert("Address not in antibot mode whitelist");
        token.transfer(userB, transferAmount);
        vm.stopPrank();
        
        console.log("SUCCESS: Transfer was blocked by antibot mode as expected");
        console.log("Vulnerability Exists: Anti-bot mode allows owner to arbitrarily block transfers from non-whitelisted addresses");
    }
}