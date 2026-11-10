// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DarlingInu.sol";

contract DarlingInuTest is Test {
    DarlingInu token;
    address constant OWNER = 0x8c919e9F79686c6D5E6336B558349E13B864D621;
    
    // Mock tokens for testing failure cases
    TokenFail tokenFail;
    address constant FAIL_TOKEN_RECIPIENT = address(0xBAD);
    uint256 constant FAIL_TOKEN_AMOUNT = 100e18;
    
    TokenFalse tokenFalse;
    address constant FALSE_TOKEN_RECIPIENT = address(0xF00BA7);
    uint256 constant FALSE_TOKEN_AMOUNT = 50e18;

    // Addresses for mock Uniswap contracts
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY_ADDR = address(0x123456);
    address constant MOCK_WETH_ADDR = address(0x789ABC);
    address constant MOCK_PAIR_ADDR = address(0xDEF101);
    
    function setUp() public {
        // Create mock router at hardcoded address
        MockRouterHardcode mockRouterTemplate = new MockRouterHardcode();
        vm.etch(HARDCODED_ROUTER, address(mockRouterTemplate).code);
        
        // Create mock factory at the address returned by router
        MockFactoryHardcode mockFactoryTemplate = new MockFactoryHardcode();
        vm.etch(MOCK_FACTORY_ADDR, address(mockFactoryTemplate).code);
        
        // Deploy main contract
        vm.startPrank(OWNER);
        token = new DarlingInu();
        vm.stopPrank();
        
        // Deploy mock tokens
        tokenFail = new TokenFail();
        tokenFalse = new TokenFalse();
        
        // Fund contract with mock tokens
        tokenFail.mint(address(token), FAIL_TOKEN_AMOUNT * 2);
        tokenFalse.mint(address(token), FALSE_TOKEN_AMOUNT * 2);
    }

    // Test the vulnerability in remove_Random_Tokens function
    function testTokenRemovalWithoutVerification() public {
        vm.startPrank(OWNER);
        
        console.log("--- BEFORE-Trigger (Expected Revert) ---");
        // Test token with failing transfer (reverts)
        vm.expectRevert(bytes("Transfer failed"));
        token.remove_Random_Tokens(
            address(tokenFail),
            FAIL_TOKEN_RECIPIENT,
            FAIL_TOKEN_AMOUNT
        );
        console.log("Revert occurred as expected for failing token");
        
        console.log("--- Trigger (Non-Reverting False Return) ---");
        // Test token that returns false on transfer
        bool result = token.remove_Random_Tokens(
            address(tokenFalse),
            FALSE_TOKEN_RECIPIENT,
            FALSE_TOKEN_AMOUNT
        );
        
        assertFalse(
            result,
            "Transfer should fail and return false but didn't"
        );
        console.log("Function call returned false without reverting");
        
        vm.stopPrank();
        
        // Final verdict based on test outcome
        console.log("--- Vulnerability Summary ---");
        console.log("Vulnerability Exists: remove_Random_Tokens returns false for tokens that fail without revert");
    }
}

// Mock UniswapV2Router implementation
contract MockRouterHardcode {
    function factory() public pure returns (address) {
        return address(0x123456); // MOCK_FACTORY_ADDR
    }

    function WETH() public pure returns (address) {
        return address(0x789ABC); // MOCK_WETH_ADDR
    }
}

// Mock UniswapV2Factory implementation
contract MockFactoryHardcode {
    function createPair(address, address) public pure returns (address) {
        return address(0xDEF101); // MOCK_PAIR_ADDR
    }
}

// Token that always reverts on transfer
contract TokenFail {
    function balanceOf(address) public pure returns (uint256) {
        return 1000e18;
    }

    function transfer(address, uint256) public pure {
        revert("Transfer failed");
    }
    
    function mint(address to, uint256 amount) public {
        // Dummy mint function
    }
}

// Token that returns false on transfer without reverting
contract TokenFalse {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function transfer(address, uint256) public pure returns (bool) {
        return false;
    }
}