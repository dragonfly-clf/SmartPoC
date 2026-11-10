// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MemeFarm.sol";

contract MockUniswapFactory {
    address public pair;
    
    constructor() {
        pair = address(0xABCD);
    }
    
    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract MockUniswapRouter {
    address private immutable _factory;
    address private immutable _weth;
    
    constructor(address factoryAddress, address wethAddress) {
        _factory = factoryAddress;
        _weth = wethAddress;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract MemeFarmBlacklistTest is Test {
    MemeFarm token;
    address constant BLACKLIST_ADMIN = 0x3aB960dCf9359083DC126222c03bfB0d2A3C9b6b;
    address constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address victim = address(0xBAD);
    address recipient = address(0xACE);

    function setUp() public {
        // Create a mock WETH address
        address wethAddress = address(0x0aB3);
        
        // Deploy mock factory and router
        MockUniswapFactory mockFactory = new MockUniswapFactory();
        MockUniswapRouter mockRouter = new MockUniswapRouter(address(mockFactory), wethAddress);
        
        // Set up mock router at expected address
        vm.etch(UNISWAP_ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        token = new MemeFarm();
        
        // Send tokens to victim (assumes test address is initial holder)
        uint256 amount = 100 * 10 ** token.decimals();
        token.transfer(victim, amount);
    }

    function testBlacklistingPreventsTransfers() public {
        console.log("--- Initial State ---");
        uint256 recipientInitialBalance = token.balanceOf(recipient);
        console.log("Recipient initial balance:", recipientInitialBalance);

        console.log("--- BEFORE-Trigger Transfer ---");
        // Victim transfers to recipient before blacklisting
        uint256 recipientBalanceBeforeFirst = token.balanceOf(recipient);
        vm.prank(victim);
        token.transfer(recipient, 1);
        uint256 recipientBalanceAfterFirst = token.balanceOf(recipient);
        uint256 firstTransferDelta = recipientBalanceAfterFirst - recipientBalanceBeforeFirst;
        console.log("First transfer: recipient balance increased by", firstTransferDelta);
        assertEq(recipientBalanceAfterFirst, recipientInitialBalance + 1, "First transfer failed");

        console.log("--- Trigger Blacklist ---");
        // Blacklist victim by admin (vulnerability trigger)
        vm.prank(BLACKLIST_ADMIN);
        token.qwidji(victim, true);
        console.log("Victim blacklisted");

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 recipientBalanceBeforeSecond = token.balanceOf(recipient);
        // Attempt second transfer after blacklisting (should fail)
        vm.prank(victim);
        vm.expectRevert();
        token.transfer(recipient, 1);
        uint256 recipientBalanceAfterSecond = token.balanceOf(recipient);
        uint256 secondTransferDelta = recipientBalanceAfterSecond - recipientBalanceBeforeSecond;
        console.log("Second transfer: recipient balance increased by", secondTransferDelta);

        // Final vulnerability verification
        if (firstTransferDelta == 1 && secondTransferDelta == 0) {
            console.log("Differential verification result: Balance change pattern matches vulnerability");
            console.log("Vulnerability Exists: Blacklist function prevents transfers after blacklisting (backdoor confirmed)");
        } else {
            console.log("Differential verification result: Unexpected balance change pattern");
            console.log("Vulnerability not Exist: Transfers were not prevented by blacklisting");
        }
    }
}