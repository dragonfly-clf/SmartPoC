// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

// Malicious token that always returns false on transfer/transferFrom
contract MaliciousToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
    
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract SCCSUncheckedTransferTest is Test {
    SCCS public sccs;
    MaliciousToken public maliciousToken;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        sccs = new SCCS();
        maliciousToken = new MaliciousToken();
        vm.stopPrank();
        
        // Mint SCCS tokens to user
        uint256 amount = 1000 * 10 ** sccs.decimals();
        vm.prank(owner);
        sccs.transfer(user, amount);
    }

    function testUncheckedTransfer() public {
        vm.startPrank(user);
        
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 userBalanceBefore = sccs.balanceOf(user);
        console.log("User balance before:", userBalanceBefore);
        
        console.log("--- Trigger Transfer ---");
        // Simulate transfer to malicious token contract
        sccs.transfer(address(maliciousToken), 100 * 10 ** sccs.decimals());
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 userBalanceAfter = sccs.balanceOf(user);
        console.log("User balance after:", userBalanceAfter);
        
        bool balanceReduced = userBalanceAfter < userBalanceBefore;
        console.log("Balance reduced:", balanceReduced);
        console.log("Vulnerability verdict:");
        
        if(balanceReduced) {
            console.log("Vulnerability Exists: User balance reduced even though malicious token returns false");
        } else {
            console.log("Vulnerability not Exist: User balance unchanged - transfer reverted correctly");
        }
        vm.stopPrank();
        
        // Final test assertion
        assertLt(userBalanceAfter, userBalanceBefore);
    }

    function testUncheckedTransferFrom() public {
        vm.startPrank(user);
        // Approve test contract to spend tokens
        sccs.approve(address(this), 1000 * 10 ** sccs.decimals());
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 userBalanceBefore = sccs.balanceOf(user);
        console.log("User balance before:", userBalanceBefore);
        
        console.log("--- Trigger TransferFrom ---");
        sccs.transferFrom(user, address(maliciousToken), 100 * 10 ** sccs.decimals());
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 userBalanceAfter = sccs.balanceOf(user);
        console.log("User balance after:", userBalanceAfter);
        
        bool balanceReduced = userBalanceAfter < userBalanceBefore;
        console.log("Balance reduced:", balanceReduced);
        console.log("Vulnerability verdict:");
        
        if(balanceReduced) {
            console.log("Vulnerability Exists: User balance reduced even though malicious token returns false");
        } else {
            console.log("Vulnerability not Exist: User balance unchanged - transferFrom reverted correctly");
        }
        
        // Final test assertion
        assertLt(userBalanceAfter, userBalanceBefore);
    }
}