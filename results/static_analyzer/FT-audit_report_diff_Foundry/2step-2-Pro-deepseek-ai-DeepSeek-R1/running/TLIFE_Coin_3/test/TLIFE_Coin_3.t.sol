// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TLIFE_Coin.sol";

contract RecoverTokenTest is Test {
    TLIFE_Coin token;
    MockToken mockToken;

    address owner = address(this);
    uint256 constant INITIAL_SUPPLY = 1000e18;

    function setUp() public {
        // Deploy TLIFE_Coin contract
        token = new TLIFE_Coin(
            payable(0),          // __TLIFEcrypt_target (set to zero)
            "TestToken",         // __TLIFEcrypt_name
            "TEST",              // __TLIFEcrypt_symbol
            18,                  // __TLIFEcrypt_decimals
            INITIAL_SUPPLY       // __TLIFEcrypt_initial
        );
        
        // Deploy mock ERC20 token
        mockToken = new MockToken();
        
        // Set initial balances
        mockToken.mint(address(token), 100e18);
        token.transfer(address(token), 10e18); // Send token to itself
    }

    // Test recovering an external token
    function testRecoverToken() public {
        // Check initial balances
        uint256 initialTokenContractBalance = mockToken.balanceOf(address(token));
        uint256 initialOwnerBalance = mockToken.balanceOf(owner);
        
        // Recover tokens
        token.recoverToken(address(mockToken), 100e18);
        
        // Validate balances after recovery
        assertEq(mockToken.balanceOf(address(token)), 0);
        assertEq(mockToken.balanceOf(owner), initialOwnerBalance + initialTokenContractBalance);
    }

    // Test recovering the token contract's own tokens
    function testRecoverSelfToken() public {
        // Check initial balances
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        
        console.log("--- BEFORE-Trigger RecoverToken ---");
        console.log("Contract balance of own token:", contractBalanceBefore);
        console.log("Owner balance of own token:", ownerBalanceBefore);
        
        console.log("--- Trigger RecoverToken ---");
        token.recoverToken(address(token), contractBalanceBefore);
        
        console.log("--- AFTER-Trigger RecoverToken ---");
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Contract balance of own token:", contractBalanceAfter);
        console.log("Owner balance of own token:", ownerBalanceAfter);
        
        // Perform differential check
        uint256 contractDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 ownerDiff = ownerBalanceAfter - ownerBalanceBefore;
        console.log("Contract balance change:", contractDiff);
        console.log("Owner balance change:", ownerDiff);
        
        // Final vulnerability verdict based on state changes
        if (contractBalanceAfter == 0 && 
            contractDiff == contractBalanceBefore && 
            ownerDiff == contractBalanceBefore) 
        {
            console.log("Vulnerability Exists: Contract allowed recovery of its own tokens");
        } else {
            console.log("Vulnerability not Exist: State changes indicate either no recovery or invalid transfer amounts");
        }
    }
}

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}