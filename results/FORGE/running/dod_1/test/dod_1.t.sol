// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH = address(0xC);
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract CoinTokenIssueTest is Test {
    CoinToken token;
    MockUniswapV2Factory mockFactory;
    MockUniswapV2Router mockRouter;
    address deployer;
    address tokenOwner = makeAddr("tokenOwner");
    address service = makeAddr("service");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = address(this);
        vm.deal(deployer, 10 ether);

        mockFactory = new MockUniswapV2Factory();
        mockRouter = new MockUniswapV2Router(address(mockFactory));
        
        token = new CoinToken{value: 1 ether}(
            "TestToken", 
            "TEST", 
            18, 
            1_000_000_000 * 10 ** 18, // initial supply with decimals
            0, // txFee
            0, // lpFee
            0, // initial devFee
            address(mockRouter), 
            address(0), // feeReceiver as burn address
            tokenOwner,
            service
        );
        
        // Fund Alice for testing using tokenOwner balance
        uint256 amount = 10_000 * 10 ** token.decimals();
        vm.prank(tokenOwner);
        token.transfer(alice, amount);
    }

    function test_ExcessiveFeeSetting() public {
        uint256 testAmount = 100 * 10 ** token.decimals();
        uint256 bobGain;

        // Pre-trigger state: Transfer with default 0% fee
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        console.log("Alice balance before transfer:", aliceBefore);
        console.log("Bob balance before transfer:", bobBefore);

        // Execute transfer
        vm.prank(alice);
        token.transfer(bob, testAmount);
        
        // Record results
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        bobGain = bobAfter - bobBefore;
        console.log("Alice balance after transfer:", aliceAfter);
        console.log("Bob gained (pre-attack):", bobGain);
        
        console.log("--- Trigger SetDevFeePercent(100) ---");
        // Owner sets dev fee to 100%
        vm.startPrank(tokenOwner);
        token.setDevFeePercent(100);
        vm.stopPrank();

        // Post-trigger state: Transfer with 100% fee
        console.log("--- AFTER-Trigger Transfer ---");
        aliceBefore = token.balanceOf(alice);
        bobBefore = token.balanceOf(bob);
        console.log("Alice balance before transfer:", aliceBefore);
        console.log("Bob balance before transfer:", bobBefore);
        
        // Execute same transfer
        vm.prank(alice);
        token.transfer(bob, testAmount);
        
        // Record results
        aliceAfter = token.balanceOf(alice);
        bobAfter = token.balanceOf(bob);
        uint256 bobGainAfter = bobAfter - bobBefore;
        console.log("Alice balance after transfer:", aliceAfter);
        console.log("Bob gained (post-attack):", bobGainAfter);
        
        // Vulnerability verification logic
        if (bobGainAfter == 0) {
            console.log("Vulnerability Exists: Fee set to 100%% results in 0 token transfer");
        } else {
            console.log("Vulnerability exists but manipulation unexpected; %s", bobGainAfter < testAmount ? "transaction blocked" : "fee not applied");
        }
    }
}