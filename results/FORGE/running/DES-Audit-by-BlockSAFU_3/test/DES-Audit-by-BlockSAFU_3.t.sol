// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol"; // Added for enhanced logging
import "../src/RebaseDividendToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x0000000000000000000000000000000000000001);
    }
}

contract MockRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0x0);
    }
}

contract MockERC20 {
    function balanceOf(address) public pure returns (uint256) { return 0; }
    function transfer(address, uint256) public pure returns (bool) { return true; }
}

contract DESHoneypotTest is Test {
    RebaseDividendToken public token;
    
    // Constructor parameters from deployment
    address constant INITIAL_HOLDER = 0xAc45ECF9F362Eee0ee7f6D1C39Bcc51F796abB09;
    address alice = address(0x1);
    address bob = address(0x2);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;

    function setUp() public {
        // Set up mock contracts at router/USDT addresses
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory));
        MockERC20 usdtMock = new MockERC20();

        vm.etch(ROUTER_ADDRESS, address(router).code);
        vm.etch(USDT_ADDRESS, address(usdtMock).code);
        
        // Deploy token
        token = new RebaseDividendToken();
        
        // Configure test environment (enable fees between alice and bob)
        token.setSwapPairList(bob, true);
        token.setFeeWhiteList(alice, false);
        token.setFeeWhiteList(bob, false);
    }

    function testFeeUnderflowRevert() public {
        uint256 transferAmount = 100 * 10**token.decimals();
        
        // Transfer initial tokens to alice
        console2.log("--- BEFORE-Trigger Actions ---");
        console2.log("Alice balance (before init transfer):", token.balanceOf(alice));
        console2.log("BOB balance (before init transfer):", token.balanceOf(bob));
        
        vm.prank(INITIAL_HOLDER);
        token.transfer(alice, transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
        console2.log("Alice balance (after init transfer):", token.balanceOf(alice));
        
        // Set fees to create 100%+ fee scenario
        console2.log("--- TRIGGER: Configure High Fees ---");
        token.setDividendFee(100);  // Dividend fee 100%
        token.setFundFee(0);
        token.setOtherFee(0);
        token.setNftFee(0);
        // Burn fee is fixed at 1% from deployment (101% total)
        console2.log("Fees set to 101% (100% dividend + 1% burn fee)");
        
        // Attempt transfer with expectation of underflow
        console2.log("--- TRIGGER: Transfer Attempt ---");
        uint256 aliceBalancePre = token.balanceOf(alice);
        uint256 bobBalancePre = token.balanceOf(bob);
        console2.log("Alice balance (pre-attempt):", aliceBalancePre);
        console2.log("BOB balance (pre-attempt):", bobBalancePre);
        
        console2.log("--- BEGIN ATTACK SIMULATION ---");
        bool reverted = false;
        vm.prank(alice);
        try token.transfer(bob, transferAmount) {
            console2.log("Transfer SUCCESSFUL (unexpected)");
        } catch {
            console2.log("Transfer REVERTED with underflow (expected)");
            reverted = true;
        }
        console2.log("--- END ATTACK SIMULATION ---");
        
        // Final state analysis
        console2.log("--- AFTER-Transfer Attempt ---");
        console2.log("Alice balance (post-attempt):", token.balanceOf(alice));
        console2.log("BOB balance (post-attempt):", token.balanceOf(bob));
        
        console2.log("--- VULNERABILITY VERDICT ---");
        if (reverted) {
            console2.log("Vulnerability Exists: Transfer reverts when fees >100%, locking funds");
        } else {
            console2.log("Vulnerability not Exist: Transfer succeeded despite 101% fee setting");
        }
    }
}