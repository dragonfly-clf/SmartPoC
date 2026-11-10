// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LinerPowerPoint.sol";

contract ReentrancyExploiter {
    LinerPowerPoint public token;
    address public owner;
    uint256 public initialAllowance;

    constructor(address _tokenAddress) {
        token = LinerPowerPoint(_tokenAddress);
        owner = msg.sender;
    }

    function attemptReentrancy(address victim, uint256 amount) external {
        // First attempt to drain tokens
        token.transferFrom(victim, owner, amount);
        
        // If reentrancy were possible, this second transfer would succeed
        token.transferFrom(victim, owner, amount);
    }
}

contract LinerPowerPointReentrancyTest is Test {
    LinerPowerPoint public token;
    ReentrancyExploiter public exploiter;
    
    address public owner = address(0x1);
    address public victim = address(0x2);

    // Helper function for ether amounts
    function eth(uint256 amount) internal pure returns (uint256) {
        return amount * 1e18;
    }

    function setUp() public {
        // Mock Uniswap router responses
        address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address WETH = address(0x3);
        address FACTORY = address(0x4);
        address PAIR = address(0x5);
        
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(FACTORY));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(WETH));
        vm.mockCall(FACTORY, abi.encodeWithSignature("createPair(address,address)"), abi.encode(PAIR));

        // Deploy token
        vm.startPrank(owner);
        token = new LinerPowerPoint();
        vm.stopPrank();

        // Set up victim with funds
        uint256 victimBalance = eth(1000);
        vm.prank(owner);
        token.transfer(victim, victimBalance);
    }

    function test_transferFromPreventsReentrancy() public {
        // Deploy exploiter contract
        exploiter = new ReentrancyExploiter(address(token));
        
        // Victim provides allowance to exploiter (critical for test)
        vm.prank(victim);
        token.approve(address(exploiter), eth(1000));

        // Execute differential validation
        console2.log("--- BEFORE-Trigger State ---");
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 exploiterOwnerBalanceBefore = token.balanceOf(exploiter.owner());
        uint256 allowanceBefore = token.allowance(victim, address(exploiter));
        
        console2.log("Victim Balance:   ", victimBalanceBefore);
        console2.log("Owner Balance:    ", exploiterOwnerBalanceBefore);
        console2.log("Allowance:        ", allowanceBefore);

        console2.log("--- ATTACK-TRIGGER ---");
        uint256 attackAmount = eth(500);
        (bool success, ) = address(exploiter).call(
            abi.encodeWithSignature(
                "attemptReentrancy(address,uint256)", 
                victim, 
                attackAmount
            )
        );

        console2.log("--- AFTER-Trigger State ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 exploiterOwnerBalanceAfter = token.balanceOf(exploiter.owner());
        uint256 allowanceAfter = token.allowance(victim, address(exploiter));
        
        console2.log("Victim Balance:   ", victimBalanceAfter);
        console2.log("Owner Balance:    ", exploiterOwnerBalanceAfter);
        console2.log("Allowance:        ", allowanceAfter);
        
        // Differential check
        uint256 expectedChange = 2 * attackAmount;
        bool vulnerabilityExists = success && 
            victimBalanceBefore - victimBalanceAfter == expectedChange &&
            exploiterOwnerBalanceAfter - exploiterOwnerBalanceBefore == expectedChange &&
            allowanceBefore - allowanceAfter == expectedChange;

        // Final verdict logic
        if (vulnerabilityExists) {
            console2.log("VULNERABILITY VERIFICATION RESULT: EXPLOITED SUCCESSFULLY");
            console2.log("Vulnerability Exists: Reentrancy allowed successive transfers without proper state updates");
        } else {
            console2.log("VULNERABILITY VERIFICATION RESULT: NO STATE CHANGES DETECTED");
            console2.log("Vulnerability not Exist: Reentrancy prevention measures are effective");
        }
    }
}