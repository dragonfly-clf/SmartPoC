// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KARMA.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFE);
    }
}

contract KarmaUniquenessTest is Test {
    KARMA karma;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");

    function setUp() public {
        vm.chainId(1);  // Set chain ID for router selection
        
        // Set up mock router and factory
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        vm.etch(routerAddress, address(new MockRouter()).code);
        
        address factoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        vm.etch(factoryAddress, address(new MockFactory()).code);
        
        // Deploy contract
        vm.startPrank(owner);
        karma = new KARMA();
        vm.stopPrank();
    }

    function test_excludeFromReward_uniqueness() public {
        vm.startPrank(owner);
        karma.excludeFromReward(user1);
        
        // Test duplicate exclusion reverts
        vm.expectRevert("Account is already excluded");
        karma.excludeFromReward(user1);
        
        vm.stopPrank();
        console2.log("Vulnerability not Exist: duplicate exclusion operation reverted, contract uniqueness enforced");
    }

    function test_includeInReward_uniqueness() public {
        vm.startPrank(owner);
        
        // Setup exclusion first
        karma.excludeFromReward(user1);
        
        // Include user
        karma.includeInReward(user1);
        
        // Test duplicate inclusion reverts
        vm.expectRevert("Account is already included");
        karma.includeInReward(user1);
        
        vm.stopPrank();
        console2.log("Vulnerability not Exist: duplicate inclusion operation reverted, contract uniqueness enforced");
    }

    function test_setExcludeFromMaxTx_uniqueness() public {
        vm.startPrank(owner);
        
        // Set to true (should succeed)
        karma.setExcludeFromMaxTransactionLimit(user1, true);
        
        // Test duplicate config reverts (true->true)
        vm.expectRevert("Account is already set to that state");
        karma.setExcludeFromMaxTransactionLimit(user1, true);
        
        // Change state (true->false - succeeds)
        karma.setExcludeFromMaxTransactionLimit(user1, false);
        
        // Test duplicate config reverts (false->false)
        vm.expectRevert("Account is already set to that state");
        karma.setExcludeFromMaxTransactionLimit(user1, false);
        
        vm.stopPrank();
        console2.log("Vulnerability not Exist: duplicate setMaxTx operation reverted, contract uniqueness enforced");
    }
}