// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SecondToken.sol";

contract MockUniswapRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }
}

contract MockUniswapFactory {
    mapping(address => mapping(address => address)) public getPair;
    mapping(uint256 => address) public allPairs;
    uint256 public allPairsLength;

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        pair = address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB)))));
        getPair[tokenA][tokenB] = pair;
        allPairs[allPairsLength] = pair;
        allPairsLength++;
        return pair;
    }
}

contract SecondTokenPrivilegeTest is Test {
    SecondToken public token;
    address public admin = address(0x1);
    address public attacker = address(0x2);
    MockUniswapFactory public mockFactory;
    MockUniswapRouter public mockRouter;
    
    function setUp() public {
        // Deploy mock Uniswap contracts
        mockFactory = new MockUniswapFactory();
        mockRouter = new MockUniswapRouter(address(mockFactory));
        
        // Deploy SecondToken with mock router and admin as multisig
        token = new SecondToken(address(mockRouter), admin);
    }

    function testPrivilegeEscalation() public {
        bytes32 adminRole = token.DEFAULT_ADMIN_ROLE();
        
        console.log("--- BEFORE-Trigger Role State ---");
        bool adminBefore = token.hasRole(adminRole, admin);
        bool attackerBefore = token.hasRole(adminRole, attacker);
        console.log("Admin has role before:", adminBefore);
        console.log("Attacker has role before:", attackerBefore);
        
        // Validate initial admin privileges
        assertTrue(adminBefore, "Admin should start with role");
        assertFalse(attackerBefore, "Attacker shouldn't start with role");
        
        console.log("--- Trigger setRoleSuperAdmin ---");
        // Admin transfers admin role to attacker
        vm.prank(admin);
        token.setRoleSuperAdmin(attacker);
        
        console.log("--- AFTER-Trigger Role State ---");
        bool adminAfter = token.hasRole(adminRole, admin);
        bool attackerAfter = token.hasRole(adminRole, attacker);
        console.log("Admin has role after:", adminAfter);
        console.log("Attacker has role after:", attackerAfter);
        
        // Perform state comparison
        bool vulnerabilityExists = false;
        if (adminBefore && !attackerBefore && !adminAfter && attackerAfter) {
            console.log("Verification: SUCCESS - Roles changed as expected");
            vulnerabilityExists = true;
        } else {
            console.log("Verification: FAILED - Unexpected role state changes");
        }
        
        // Verify role transfer completed
        assertFalse(adminAfter, "Original admin should lose role");
        assertTrue(attackerAfter, "Attacker should gain admin role");
        
        // Verify consequences of role loss
        vm.prank(admin);
        vm.expectRevert();
        token.grantRole(adminRole, admin);
        
        // Verify attacker can grant new privileges
        vm.startPrank(attacker);
        token.grantRole(token.MINTER_ROLE(), attacker);
        token.mint(attacker, 100 ether);
        assertEq(token.balanceOf(attacker), 100 ether, "Attacker should mint tokens");
        
        // Print final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Admin role successfully transferred to attacker");
        } else {
            console.log("Vulnerability not Exist: Unexpected role state transition");
        }
    }
}