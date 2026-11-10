// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SkeletonKey.sol";

contract MaliciousToken {
    bool public shouldFail;
    mapping(address => uint256) public balanceOf;

    function setFail(bool _shouldFail) external {
        shouldFail = _shouldFail;
    }

    function transfer(address, uint256) external view returns (bool) {
        return !shouldFail;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

contract SkeletonKeyTest is Test {
    SkeletonKey token;
    MaliciousToken maliciousToken;
    address tokenOwner;

    function setUp() public {
        address deployer = vm.addr(1);
        vm.startPrank(deployer);
        token = new SkeletonKey();
        vm.stopPrank();
        
        tokenOwner = token.owner();
        console.log("Token owner: ", tokenOwner);
        
        maliciousToken = new MaliciousToken();
        // Mint tokens to token contract address
        maliciousToken.mint(address(token), 100 ether);

        // Make sure owner is funded for gas
        vm.deal(tokenOwner, 10 ether);
    }

    function test_RescueTokensFailsSilently() public {
        maliciousToken.setFail(true);
        
        vm.startPrank(tokenOwner);
        console.log("--- BEFORE-Trigger Check ---");
        uint256 initialOwnerBalance = maliciousToken.balanceOf(tokenOwner);
        uint256 initialTokenBalance = maliciousToken.balanceOf(address(token));
        console.log("Owner malicious token balance (before):", initialOwnerBalance);
        console.log("Token contract malicious token balance (before):", initialTokenBalance);

        console.log("--- Trigger: Process_Rescue_Tokens---");
        token.Process_Rescue_Tokens(address(maliciousToken), 100 ether);

        console.log("--- AFTER-Trigger Check ---");
        uint256 finalOwnerBalance = maliciousToken.balanceOf(tokenOwner);
        uint256 finalTokenBalance = maliciousToken.balanceOf(address(token));
        console.log("Owner malicious token balance (after):", finalOwnerBalance);
        console.log("Token contract malicious token balance (after):", finalTokenBalance);
        vm.stopPrank();
        
        console.log("--- Differential Result ---");
        bool stateChanged = (finalOwnerBalance != initialOwnerBalance) || 
                            (finalTokenBalance != initialTokenBalance);
        
        if (stateChanged) {
            console.log("ALERT: State changed during silent failure!");
            console.log("Vulnerability not Exist: Rescue operation changed state despite malicious token revert");
        } else {
            console.log("ALERT: State unchanged after silent failure!");
            console.log("Vulnerability Exists: Malicious token transfer failed silently without state rollback");
        }
    }
}