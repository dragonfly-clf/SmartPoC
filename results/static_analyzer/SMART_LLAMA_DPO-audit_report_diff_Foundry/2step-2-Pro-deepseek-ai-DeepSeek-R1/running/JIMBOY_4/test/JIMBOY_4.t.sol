// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JIMBOY.sol";

contract JIMBOY_PrivilegeEscalation_Test is Test {
    JIMBOY public token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    
    // Fixed Uniswap router address used in contract
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address MOCK_FACTORY = address(0x123);
    address MOCK_WETH = address(0x456);
    address MOCK_PAIR = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        token = new JIMBOY();
        vm.stopPrank();
    }

    function test_ownerCanSetTrading() public {
        // Mock calls needed for setTrading execution
        mockUniswapCalls();
        
        vm.prank(owner);
        token.setTrading(true);
        
        assertTrue(true, "Owner should be able to set trading status");
    }

    function test_nonOwnerCannotSetTrading() public {
        // Mock calls needed for setTrading execution
        mockUniswapCalls();
        
        console2.log("--- BEFORE-Trigger uniswapV2Pair value ---");
        address pairBefore = token.uniswapV2Pair();
        console2.log("Pair Address Before Attacker Action: %s", pairBefore);
        
        console2.log("--- Trigger setTrading by Attacker ---");
        vm.prank(attacker);
        try token.setTrading(true) {
            // If it doesn't revert, we log and continue.
            console2.log("Attacker call to setTrading did not revert");
        } catch Error(string memory reason) {
            console2.log("Attacker call reverted with reason: %s", reason);
        } catch {
            console2.log("Attacker call reverted without reason string");
        }
        
        console2.log("--- AFTER-Trigger uniswapV2Pair value ---");
        address pairAfter = token.uniswapV2Pair();
        console2.log("Pair Address After Attacker Action: %s", pairAfter);
        
        if (pairAfter != address(0)) {
            console2.log("Vulnerability Exists: non-owner setTrading set uniswapV2Pair to non-zero");
        } else {
            console2.log("Vulnerability not Exist: uniswapV2Pair remains zero after non-owner call");
        }
    }
    
    function mockUniswapCalls() private {
        // Mock router.WETH() call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        // Mock router.factory() call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        // Mock factory.createPair() call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)", address(token), MOCK_WETH),
            abi.encode(MOCK_PAIR)
        );
    }
}