// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract ETHReceiver {
    receive() external payable {}
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockUniswapV2Router {
    address public factory;

    constructor(address _factory) public {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract CoinTokenTest is Test {
    CoinToken token;
    ETHReceiver owner;
    address service;

    function setUp() public {
        // Create ETH capable owner and service
        owner = new ETHReceiver();
        service = makeAddr("service");
        
        // Setup mocks
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory));
        
        // Deploy token with funds for service payment
        vm.deal(address(owner), 10 ether);
        vm.prank(address(owner));
        token = (new CoinToken){value: 1 ether}(
            "TestToken", 
            "TT", 
            18,
            1000000,
            2,
            3,
            500000,
            100000,
            address(mockRouter),
            address(owner),
            service
        );
    }

    function testOwnerCanDrainContractBalance() public {
        // Fund token contract
        uint256 amountDrain = 1 ether;
        vm.deal(address(token), amountDrain);
        
        // Record balances
        uint256 tokenContractBalanceBefore = address(token).balance;
        uint256 ownerBalanceBefore = owner.getBalance();
        address tokenOwnerBefore = token.owner();
        
        // Differential logging
        console.log("--- BEFORE-Trigger claimTokens ---");
        console.log("Token contract ETH balance: ", tokenContractBalanceBefore);
        console.log("Owner ETH balance: ", ownerBalanceBefore);
        console.log("Token owner: ", tokenOwnerBefore);
        
        console.log("--- Trigger claimTokens ---");
        // Trigger drain function
        vm.prank(address(owner));
        token.claimTokens();
        
        console.log("--- AFTER-Trigger claimTokens ---");
        uint256 tokenContractBalanceAfter = address(token).balance;
        uint256 ownerBalanceAfter = owner.getBalance();
        address tokenOwnerAfter = token.owner();
        console.log("Token contract ETH balance: ", tokenContractBalanceAfter);
        console.log("Owner ETH balance: ", ownerBalanceAfter);
        console.log("Token owner: ", tokenOwnerAfter);
        
        // Vulnerability verification logic
        bool balanceTransferred = ownerBalanceAfter == ownerBalanceBefore + tokenContractBalanceBefore;
        bool contractDrained = tokenContractBalanceAfter == 0;
        bool ownerUnchanged = tokenOwnerAfter == tokenOwnerBefore;
        
        if (contractDrained && balanceTransferred && ownerUnchanged) {
            console.log("Vulnerability Exists: Drain successful with unchanged ownership");
        } else {
            if (!contractDrained) console.log("Contract not drained. Balance: %s", tokenContractBalanceAfter);
            if (!balanceTransferred) console.log("Funds not transferred to owner");
            if (!ownerUnchanged) console.log("Token ownership changed");
            console.log("Vulnerability not Exist: Drain conditions not satisfied");
        }
        
        // Original assertions preserved
        assertEq(tokenContractBalanceAfter, 0, "Contract should be drained");
        assertEq(ownerBalanceAfter, ownerBalanceBefore + tokenContractBalanceBefore, "Owner should receive funds");
        assertEq(tokenOwnerAfter, tokenOwnerBefore, "Owner address should remain unchanged");
    }
}