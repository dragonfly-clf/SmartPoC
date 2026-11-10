// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHANKS_INU.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890);
    }
}

contract MockRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function initialize(address _factory) public {
        factory = _factory;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure {}
    
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) { return (0, 0, 0); }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address, uint
    ) external payable {}
}

contract SHANKS_Test is Test {
    SHANKS_INU token;
    address constant DEAD = address(0xdead);
    address constant WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address owner;
    address user = address(0x123);
    address presaler = 0x410876C017bab6C4C9c595c34F6F21648847BEeD;
    
    function setUp() public {
        owner = address(this);
        
        // Setup mock router
        address targetRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        MockFactory mockFactory = new MockFactory();
        address templateRouter = address(new MockRouter(address(mockFactory)));
        vm.etch(targetRouter, templateRouter.code);
        MockRouter(targetRouter).initialize(address(mockFactory));
        
        // Deploy token with presaler as initial holder
        vm.prank(presaler);
        token = new SHANKS_INU();
        
        // Authorize test contract to call authorized functions
        vm.prank(presaler);
        token.authorize(address(this));
        
        // Configure fees and limits
        token.setFees(1, 1, 1, 1, 100);
        token.setTxLimit(100 ether);
        token.setSwapBackSettings(true, 1 ether);
        token.setAutoBuybackSettings(true, 10 ether, 1 ether, 1, false);
        
        // Fund user with tokens
        uint256 userBalance = 1 ether;
        vm.prank(presaler);
        token.transfer(user, userBalance);
        
        // Fund user with ETH for any potential buybacks
        vm.deal(user, 100 ether);
    }

    function test_InconsistentSwapStateUpdate() public {
        // BEFORE: Record initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialEthBalance = address(token).balance;
        uint256 initialDeadBalance = token.balanceOf(DEAD);
        console.log("Contract ETH balance pre: %s", initialEthBalance);
        console.log("DEAD token balance pre: %s", initialDeadBalance);

        // Fund contract with ETH
        vm.deal(address(token), 1 ether);  // +1 ETH
        
        console.log("\n--- Trigger Action ---");
        // Disable swapping
        token.setSwapBackSettings(false, 0);
        
        // Transfer tokens to contract to trigger potential swap
        vm.prank(user);
        token.transfer(address(token), 0.1 ether);
        console.log("Executed transfer with swap disabled");

        // AFTER: Capture new state
        console.log("\n--- AFTER-Trigger State ---");
        uint256 updatedEthBalance = address(token).balance;
        uint256 updatedDeadBalance = token.balanceOf(DEAD);
        console.log("Contract ETH balance post: %s", updatedEthBalance);
        console.log("DEAD token balance post: %s", updatedDeadBalance);

        // Compare results
        console.log("\n--- Vulnerability Verification ---");
        bool ethChanged = updatedEthBalance != initialEthBalance + 1 ether;
        bool deadChanged = updatedDeadBalance != initialDeadBalance;
        
        console.log("Result: ETH balance changed -> %s", ethChanged ? "Yes" : "No");
        console.log("Result: DEAD balance changed -> %s", deadChanged ? "Yes" : "No");

        // Final verdict
        if (ethChanged || deadChanged) {
            console.log("Vulnerability Exists: State inconsistency detected after swap disable");
        } else {
            console.log("Vulnerability not Exist: Swap state consistency verified");
        }

        // Original test assertion
        assertEq(
            address(token).balance,
            initialEthBalance + 1 ether,
            "Swap executed despite being disabled"
        );
    }
    
    function test_InconsistentBuybackStateUpdate() public {
        // BEFORE: Record initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialEthBalance = address(token).balance;
        uint256 initialDeadBalance = token.balanceOf(DEAD);
        console.log("Contract ETH balance pre: %s", initialEthBalance);
        console.log("DEAD token balance pre: %s", initialDeadBalance);

        // Fund token contract with ETH for buybacks
        vm.deal(address(token), 10 ether);  // +10 ETH
        
        console.log("\n--- Trigger Action ---");
        // Disable auto-buyback
        token.setAutoBuybackSettings(false, 0, 0, 0, false);
        
        // Transfer tokens to contract to trigger potential buyback
        vm.prank(user);
        token.transfer(address(token), 0.1 ether);
        console.log("Executed transfer with buyback disabled");

        // AFTER: Capture new state
        console.log("\n--- AFTER-Trigger State ---");
        uint256 updatedEthBalance = address(token).balance;
        uint256 updatedDeadBalance = token.balanceOf(DEAD);
        console.log("Contract ETH balance post: %s", updatedEthBalance);
        console.log("DEAD token balance post: %s", updatedDeadBalance);

        // Compare results
        console.log("\n--- Vulnerability Verification ---");
        bool ethChanged = updatedEthBalance != initialEthBalance + 10 ether;
        bool deadChanged = updatedDeadBalance != initialDeadBalance;
        
        console.log("Result: ETH balance changed -> %s", ethChanged ? "Yes" : "No");
        console.log("Result: DEAD balance changed -> %s", deadChanged ? "Yes" : "No");

        // Final verdict
        if (ethChanged || deadChanged) {
            console.log("Vulnerability Exists: State inconsistency detected after buyback disable");
        } else {
            console.log("Vulnerability not Exist: Buyback state consistency verified");
        }

        // Original test assertion
        assertEq(
            token.balanceOf(DEAD),
            initialDeadBalance,
            "Auto-buyback executed despite being disabled"
        );
    }
}