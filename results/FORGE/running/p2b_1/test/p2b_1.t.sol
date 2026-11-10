// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Play2Burn.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }

    function WETH() external pure returns (address) {
        return address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract OwnerTokensDrainTest is Test {
    Play2Burn token;
    uint256 constant TEST_AMOUNT = 1 ether;
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDR = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        // Deploy mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();

        // Override router and factory at required addresses
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.etch(FACTORY_ADDR, address(mockFactory).code);

        // Deploy token contract
        token = new Play2Burn();
        
        // Fund token contract with native currency
        vm.deal(address(token), TEST_AMOUNT);
        
        // Fund test contract for balance checks
        vm.deal(address(this), 1000 ether);
    }

    receive() external payable {}  // Enable ETH reception

    function testOwnerCanDrainNativeTokens() public {
        // Capture initial balances
        uint256 initialTokenBalance = address(token).balance;
        uint256 initialOwnerBalance = token.owner().balance;

        console.log("--- BEFORE-Trigger Balances ---");
        console.log("Contract balance (ETH): %s", initialTokenBalance);
        console.log("Owner balance (ETH): %s", initialOwnerBalance);

        console.log("--- Trigger Drain Operation ---");
        // Execute drain function as contract owner
        vm.prank(token.owner());
        token.claimStuckTokens(address(0));

        // Capture post-drain balances
        uint256 newTokenBalance = address(token).balance;
        uint256 newOwnerBalance = token.owner().balance;

        console.log("--- AFTER-Trigger Balances ---");
        console.log("Contract balance (ETH): %s", newTokenBalance);
        console.log("Owner balance (ETH): %s", newOwnerBalance);

        // Differential verification
        bool contractBalanceReset = (newTokenBalance == 0);
        bool ownerReceivedFunds = (newOwnerBalance == initialOwnerBalance + initialTokenBalance);
        bool drainSuccessful = contractBalanceReset && ownerReceivedFunds;

        console.log("Contract balance reset: ", contractBalanceReset ? "YES" : "NO");
        console.log("Owner received funds:   ", ownerReceivedFunds ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (drainSuccessful) {
            console.log("Vulnerability Exists: Owner successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: Drain operation did not transfer funds as expected");
        }
    }

    function testPreventTokenSelfDrain() public {
        // Attempt to drain the token contract's own tokens
        vm.prank(token.owner());
        
        // Should revert with custom error
        vm.expectRevert("No rug pulls :)");
        token.claimStuckTokens(address(token));
    }
}