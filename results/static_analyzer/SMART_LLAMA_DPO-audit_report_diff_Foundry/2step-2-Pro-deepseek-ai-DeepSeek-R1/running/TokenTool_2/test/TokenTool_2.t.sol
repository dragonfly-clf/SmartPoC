// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract TokenToolTest is Test {
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address owner = address(this);
    TokenTool token1;
    TokenTool token2;
    MockRouter mockRouter;
    address mockMarketPair = address(0x200);
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        // Deploy mock router
        mockRouter = new MockRouter();

        // Deploy two token instances
        token1 = new TokenTool(
            "Token1", "T1", 18, 1000000, 
            address(mockRouter), 
            owner, 
            address(0x333), 
            address(0x444), 
            address(0x555)
        );

        token2 = new TokenTool(
            "Token2", "T2", 18, 1000000, 
            address(mockRouter), 
            owner, 
            address(0x333), 
            address(0x444), 
            address(0x555)
        );

        // Configure both tokens
        token1.setMarketPairStatus(mockMarketPair, true);
        token2.setMarketPairStatus(mockMarketPair, true);

        token1.setSellDestFee(1); // 1%
        token2.setSellDestFee(1); // 1%

        token1.setIsWalletLimitExempt(mockMarketPair, true);
        token2.setIsWalletLimitExempt(mockMarketPair, true);

        // Distribute tokens to test users
        token1.transfer(user1, 1000 * 10**18);
        token2.transfer(user2, 1000 * 10**18);
    }

    function testDeadAddressReuse() public {
        uint256 amount = 100 * 10**18;
        
        console.log("--- BEFORE-Trigger DEAD Balances ---");
        uint256 token1DeadBefore = token1.balanceOf(DEAD);
        uint256 token2DeadBefore = token2.balanceOf(DEAD);
        console.log("Token1 DEAD Balance (Before):", token1DeadBefore);
        console.log("Token2 DEAD Balance (Before):", token2DeadBefore);

        console.log("--- Trigger Burn Operations ---");
        // Trigger burns in both tokens
        vm.prank(user1);
        token1.transfer(mockMarketPair, amount);

        vm.prank(user2);
        token2.transfer(mockMarketPair, amount);

        console.log("--- AFTER-Trigger DEAD Balances ---");
        uint256 token1DeadAfter = token1.balanceOf(DEAD);
        uint256 token2DeadAfter = token2.balanceOf(DEAD);
        console.log("Token1 DEAD Balance (After):", token1DeadAfter);
        console.log("Token2 DEAD Balance (After):", token2DeadAfter);

        uint256 token1Burned = token1DeadAfter - token1DeadBefore;
        uint256 token2Burned = token2DeadAfter - token2DeadBefore;
        console.log("Token1 Burned Amount:", token1Burned);
        console.log("Token2 Burned Amount:", token2Burned);

        // Verify vulnerability using differential validation
        bool vulnerabilityExists = (token1Burned == 1 * 10**18) && 
                                  (token2Burned == 1 * 10**18);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Both tokens successfully burned tokens to DEAD address");
        } else {
            console.log("Vulnerability not Exist: Burn amounts didn't match expected values");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123456);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public constant WETH = address(0x999);
    
    constructor() {
        factory = new MockFactory();
    }
}