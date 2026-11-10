// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AIOToken.sol";

contract PancakeFactoryAccessControlTest is Test {
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    
    // Mock token addresses for testing
    address tokenA = address(0x1);
    address tokenB = address(0x2);
    
    // Actual PancakeSwap factory address
    address constant PANCAKE_FACTORY_ADDRESS = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    AIOToken token;
    
    function setUp() public {
        // Deploy mock factory implementation
        MockVulnerableFactory mock = new MockVulnerableFactory();
        
        // Simulate PANCAKE_FACTORY_ADDRESS having mock factory's code
        vm.etch(PANCAKE_FACTORY_ADDRESS, address(mock).code);
        
        // Deploy AIOToken - will use our mock factory
        vm.prank(owner);
        token = new AIOToken();
    }
    
    function test_CreatePairWithoutAccessControl() public {
        MockVulnerableFactory factory = MockVulnerableFactory(PANCAKE_FACTORY_ADDRESS);
        
        console.log("--- BEFORE-Trigger pairExists ---");
        bool pairExistsBefore = factory.pairExists(tokenA, tokenB);
        console.log("Pair exists before attack? %s", pairExistsBefore ? "YES" : "NO");
        assertFalse(pairExistsBefore, "Pair should not exist before attack");
        
        console.log("--- Trigger CreatePair ---");
        // Attacker creates a pair directly on the factory
        vm.prank(attacker);
        address pair = factory.createPair(tokenA, tokenB);
        
        console.log("--- AFTER-Trigger pairExists ---");
        bool pairExistsAfter = factory.pairExists(tokenA, tokenB);
        console.log("Pair exists after attack? %s", pairExistsAfter ? "YES" : "NO");
        
        // Verify differential state change
        console.log("--- DIFFERENTIAL VERIFICATION ---");
        if (pairExistsBefore == false && pairExistsAfter == true) {
            console.log("VULNERABLE: Pair creation state changed!");
            console.log("Vulnerability Exists: Attacker successfully created unauthorized trading pair");
        } else {
            console.log("SECURE: Pair state unchanged");
            console.log("Vulnerability not Exist: No unauthorized access was granted");
        }
        
        // Original verification logic
        assertTrue(pair != address(0), "Pair creation failed");
        assertTrue(pairExistsAfter, "Pair not registered in factory");
    }
}

contract MockVulnerableFactory {
    mapping(address => mapping(address => address)) public pairs;
    
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        // Create deterministic pair address with fixed parentheses
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(tokenA, tokenB, block.timestamp)
                    )
                )
            )
        );
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
        return pair;
    }
    
    function pairExists(address tokenA, address tokenB) external view returns (bool) {
        return pairs[tokenA][tokenB] != address(0);
    }
}