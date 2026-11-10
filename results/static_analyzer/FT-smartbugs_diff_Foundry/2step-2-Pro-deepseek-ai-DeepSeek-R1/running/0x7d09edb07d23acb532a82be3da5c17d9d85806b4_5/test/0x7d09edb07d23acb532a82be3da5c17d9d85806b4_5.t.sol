// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol"; // Added console2 import
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract MockERC20 {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract PoCGameTest is Test {
    PoCGame public game;
    MockERC20 public token;
    address public owner = makeAddr("owner");
    address public whale = makeAddr("whale");
    address public victim = makeAddr("victim");
    uint256 public wagerLimit = 1 ether;
    uint256 public initialTokenBalance = 1000 ether;

    function setUp() public {
        vm.prank(owner);
        game = new PoCGame(whale, wagerLimit);
        
        token = new MockERC20();
        token.mint(address(game), initialTokenBalance);
    }

    function test_ownerCanTransferTokensWithoutApproval() public {
        uint256 gameBalanceBefore = token.balanceOf(address(game));
        uint256 victimBalanceBefore = token.balanceOf(victim);

        console2.log("--- BEFORE-Trigger Transfer ---");
        console2.log("Game Contract Token Balance (Before):", gameBalanceBefore);
        console2.log("Victim Token Balance (Before):", victimBalanceBefore);

        console2.log("--- Trigger Transfer ---");
        vm.prank(owner);
        game.transferAnyERC20Token(address(token), victim, 500 ether);

        uint256 gameBalanceAfter = token.balanceOf(address(game));
        uint256 victimBalanceAfter = token.balanceOf(victim);

        console2.log("--- AFTER-Trigger Transfer ---");
        console2.log("Game Contract Token Balance (After):", gameBalanceAfter);
        console2.log("Victim Token Balance (After):", victimBalanceAfter);

        uint256 gameBalanceChange = gameBalanceBefore - gameBalanceAfter;
        uint256 victimBalanceChange = victimBalanceAfter - victimBalanceBefore;
        console2.log("Game Balance Change:", gameBalanceChange);
        console2.log("Victim Balance Change:", victimBalanceChange);

        bool vulnerabilityExists = (gameBalanceChange == 500 ether) && 
                                  (victimBalanceChange == 500 ether);

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Owner can transfer tokens without approval");
        } else {
            console2.log("Vulnerability not Exist: Token balances did not change by expected amount (500 ether)");
        }

        assertEq(token.balanceOf(address(game)), initialTokenBalance - 500 ether);
        assertEq(token.balanceOf(victim), 500 ether);
    }

    function test_nonOwnerCannotTransferTokens() public {
        vm.prank(victim);
        vm.expectRevert();
        game.transferAnyERC20Token(address(token), victim, 500 ether);
    }
}