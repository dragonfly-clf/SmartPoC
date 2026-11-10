// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/junkoInu.sol";

contract JunkoInuEventTest is Test {
    junkoInu token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 initialSupply;

    event TokenBurned(address indexed account, address indexed token, uint256 amount);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock calls to Uniswap router and factory
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        address mockPair = address(0x789);

        // Mock router factory() call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        token = new junkoInu();
        vm.stopPrank();
        
        initialSupply = token.balanceOf(owner);
    }

    function testBurnWithoutTokenBurnedEvent() public {
        uint256 burnAmount = 1000 * 10 ** token.decimals();
        
        // Transfer tokens to user to test burning from another account
        vm.prank(owner);
        token.transfer(user, burnAmount);
        
        // Record all emitted events
        vm.recordLogs();
        
        // Attempt to burn tokens from user's account
        vm.prank(owner);
        token._burn(user, burnAmount);

        // Check logs for TokenBurned event
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 tokenBurnedEvent = keccak256("TokenBurned(address,address,uint256)");
        
        bool eventFound = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == tokenBurnedEvent) {
                eventFound = true;
                break;
            }
        }
        
        // Final vulnerability verdict
        if (eventFound) {
            revert("Vulnerability not Exist: TokenBurned event emitted as expected");
        } else {
            console.log("Vulnerability Exists: TokenBurned event not emitted during burn");
        }
    }
}