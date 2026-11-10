// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract MockRouter {
    event Deadlines(uint256 tokenAmount, uint256 deadline);
    
    address public factory;
    address public immutable WETH = address(0x1);
    uint256 public lastDeadline;
    
    constructor() {
        factory = address(this);
    }
    
    function createPair(address, address) external returns (address) {
        return address(0xabc); // mock pair address
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 tokenAmount,
        uint256,
        address[] calldata,
        address,
        uint256 deadline
    ) external {
        lastDeadline = deadline;
        emit Deadlines(tokenAmount, deadline);
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        lastDeadline = deadline;
        return (0, 0, 0);
    }
}

contract TokenToolTimestampTest is Test {
    TokenTool token;
    MockRouter router;
    
    address owner = makeAddr("owner");
    address marketing = makeAddr("marketing");
    address team = makeAddr("team");
    address service = makeAddr("service");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    
    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        router = new MockRouter();
        
        vm.prank(owner);
        token = new TokenTool{value: 0.1 ether}(
            "TestToken", 
            "TEST", 
            18, 
            1_000_000, // 1M tokens
            address(router),
            owner,
            marketing,
            team,
            service
        );
        
        // Configure token with swap enabled
        vm.startPrank(owner);
        token.setSwapAndLiquifyEnabled(true);
        token.setSwapAndLiquifyByLimitOnly(false);
        token.setMarketPairStatus(address(0xabc), true);
        token.setNumTokensBeforeSwap(1 * 10**18); // Set min tokens to 1
        token.setDistributionSettings(0, 0, 100); // Send all to team for simplicity
        token.setBuyTaxes(10, 0, 0); // 10% buy fee
        token.setSelTaxes(5, 0, 0);  // 5% sell fee
        token.setIsTxLimitExempt(address(0xabc), true); // Exempt mock pair
        token.transfer(address(0xabc), 1000 * 10**18); // Fund mock pair
        vm.stopPrank();
    }

    function testTimestampManipulation() public {
        // Set swap threshold to 0 to ensure each transfer triggers swap
        vm.prank(owner);
        token.setNumTokensBeforeSwap(0);

        // Buy tokens to accumulate fees in contract
        address mockPair = address(0xabc);
        vm.prank(mockPair);
        token.transfer(user1, 10 * 10**18);
        
        // Contract should have 1 token from 10 token buy (10% fee)
        assertEq(token.balanceOf(address(token)), 1 * 10**18, "Fees not collected");
        
        console.log("--- BEFORE-Trigger Transfer 1 ---");
        uint256 originalTime;
        uint256 preDeadline;
        {
            // Get current block timestamp before transfer
            originalTime = block.timestamp;
            console.log("Original block.timestamp:", originalTime);
            
            // Trigger first swap via transfer
            vm.prank(user1);
            token.transfer(user2, 1 * 10**18);
            
            // Capture router deadline after first swap
            preDeadline = router.lastDeadline();
            console.log("Deadline recorded from first swap:", preDeadline);
        }
        
        console.log("--- Trigger Warp Function (timestamp manipulation) ---");
        uint256 manipulatedTime = originalTime + 3600;
        vm.warp(manipulatedTime);
        console.log("Manipulated block.timestamp:", manipulatedTime);
        
        console.log("--- AFTER-Trigger Transfer 2 ---");
        uint256 postDeadline;
        {
            // Trigger second swap via transfer after warp
            vm.prank(user1);
            token.transfer(user2, 1 * 10**18);
            
            // Capture router deadline after second swap
            postDeadline = router.lastDeadline();
            console.log("Deadline recorded from second swap:", postDeadline);
        }
        
        // Validation logic
        bool deadlinesDiffer = (preDeadline != postDeadline);
        bool timestampManipulated = (postDeadline == manipulatedTime);
        
        if (deadlinesDiffer && timestampManipulated) {
            console.log("Vulnerability Exists: Swap uses manipulable block.timestamp for deadline");
        } else {
            console.log("Vulnerability not Exist: Deadline remains consistent with real time");
        }
    }
}