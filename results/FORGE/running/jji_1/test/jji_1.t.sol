// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JujutsuInu.sol";

contract MockRouter {
    address public immutable WETH;
    address public factory;
    
    constructor(address _weth, address _factory) {
        WETH = _weth;
        factory = _factory;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract JujutsuInuTest is Test {
    JujutsuInu token;
    MockRouter router;
    address owner = address(this);
    address constant MOCK_WETH = address(0x0);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function setUp() public {
        MockFactory factory = new MockFactory();
        router = new MockRouter(MOCK_WETH, address(factory));
        token = new JujutsuInu(address(router));
        
        // Mint tokens to test user for transfer simulation
        uint256 INIT_TOKENS = 1000 * 10 ** token.decimals();
        token.transfer(user1, INIT_TOKENS);
    }

    function test_fee_setting_exceeds_max_permission() public {
        // Verify test contract is owner
        assertTrue(token.isOwner(address(this)));
        
        console.log("--- BEFORE-Trigger Transfer Simulation ---");
        uint256 transferAmount = 100 * 10 ** token.decimals();
        
        uint256 totalBefore = token.balanceOf(user1) + token.balanceOf(user2);
        uint256 user1Before = token.balanceOf(user1);
        
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        uint256 totalAfter = token.balanceOf(user1) + token.balanceOf(user2);
        uint256 feeTakenBefore = totalBefore - totalAfter;
        console.log("Initial transfer fee tokens:", feeTakenBefore);
        console.log("Initial effective fee rate: %", 
            (feeTakenBefore * 10000) / transferAmount);

        console.log("--- Trigger setFees(3000,3000,10000) ---");
        token.setFees(3000, 3000, 10000); // Attempt 30% buy/sell fees

        console.log("--- AFTER-Trigger Transfer Simulation ---");
        totalBefore = token.balanceOf(user1) + token.balanceOf(user2);
        user1Before = token.balanceOf(user1);
        
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        totalAfter = token.balanceOf(user1) + token.balanceOf(user2);
        uint256 feeTakenAfter = totalBefore - totalAfter;
        console.log("Post-attack transfer fee tokens:", feeTakenAfter);
        console.log("Post-attack effective fee rate: %", 
            (feeTakenAfter * 10000) / transferAmount);
        
        // Normalize based on initial fee for comparison
        uint256 feeIncreaseFactor = feeTakenAfter * 10000 / 
            (feeTakenBefore > 0 ? feeTakenBefore : 1000);
        bool vulnExists = feeTakenAfter > feeTakenBefore &&
            feeIncreaseFactor > 10000;
        
        console.log("Fee increase factor: %", feeIncreaseFactor / 100);
        console.log("Vulnerability exists? %s", 
            vulnExists ? "YES" : "NO"
        );
        
        // Final verdict
        if (vulnExists) {
            console.log("Vulnerability Exists: Transfer fees increased after setting unreasonably high fees");
        } else if (feeTakenAfter == 0) {
            console.log("Vulnerability not Exist: Fee implementation did not take effect after configuration change");
        } else {
            console.log("Vulnerability not Exist: Fee increase within expected parameters");
        }
    }
}