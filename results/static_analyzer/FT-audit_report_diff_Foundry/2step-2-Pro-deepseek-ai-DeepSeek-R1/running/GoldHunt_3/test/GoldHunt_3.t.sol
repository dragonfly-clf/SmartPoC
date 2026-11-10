// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract GoldHuntTest is Test {
    GoldHunt public token;
    address public owner;
    address public rewardsPool;
    MockPair public mockPair;
    uint256 public constant TEST_AMOUNT = 1000 ether;
    uint256 public initialSupply;
    
    function setUp() public {
        owner = makeAddr("owner");
        rewardsPool = makeAddr("rewardsPool");
        
        // Deploy mock pair
        mockPair = new MockPair();
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new GoldHunt();
        token.setRewardsPool(rewardsPool);
        token.setPair(address(mockPair));
        
        // Transfer initial tokens to rewards pool
        token.transfer(rewardsPool, TEST_AMOUNT);
        initialSupply = token.totalSupply();
        vm.stopPrank();
    }

    function test_UnboundedTokenMinting() public {
        // Get initial raw supply
        uint256 initialRawSupply = initialSupply * token.rebaseMultiple();
        console.log("--- BEFORE-Trigger Operation ---");
        console.log("Initial raw supply: %s", initialRawSupply);
        
        // First rebase (2x multiplier)
        console.log("--- Trigger first rebase ---");
        vm.prank(owner);
        token.rebase(2);
        
        // After first rebase
        console.log("--- AFTER-Trigger Operation ---");
        uint256 afterFirstRebase = token.totalSupply() * token.rebaseMultiple();
        uint256 firstIncrease = afterFirstRebase - initialRawSupply;
        console.log("Raw supply after first rebase: %s", afterFirstRebase);
        console.log("Increase from first rebase: %s", firstIncrease);
        
        // Before second rebase
        console.log("--- BEFORE-Trigger Operation ---");
        uint256 beforeSecondRebase = afterFirstRebase;
        console.log("Raw supply before second rebase: %s", beforeSecondRebase);
        
        // Second rebase (2x multiplier)
        console.log("--- Trigger second rebase ---");
        vm.prank(owner);
        token.rebase(2);
        
        // After second rebase
        console.log("--- AFTER-Trigger Operation ---");
        uint256 afterSecondRebase = token.totalSupply() * token.rebaseMultiple();
        uint256 secondIncrease = afterSecondRebase - beforeSecondRebase;
        console.log("Raw supply after second rebase: %s", afterSecondRebase);
        console.log("Increase from second rebase: %s", secondIncrease);
        
        // Vulnerability verdict
        if (firstIncrease == TEST_AMOUNT && secondIncrease == TEST_AMOUNT) {
            console.log("Vulnerability Exists: Each rebase operation mints TEST_AMOUNT tokens, enabling unbounded supply expansion");
        } else {
            console.log("Vulnerability not Exist: Expected TEST_AMOUNT per rebase but got %s and %s instead", firstIncrease, secondIncrease);
        }
    }
    
    function _getRawTotalSupply() internal view returns (uint256) {
        return token.totalSupply() * token.rebaseMultiple();
    }
}

contract MockPair {
    function sync() external {
        // Mock implementation for test
    }
}