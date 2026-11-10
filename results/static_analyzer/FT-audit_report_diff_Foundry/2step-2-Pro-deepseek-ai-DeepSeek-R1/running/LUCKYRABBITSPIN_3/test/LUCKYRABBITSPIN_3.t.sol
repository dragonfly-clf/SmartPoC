// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LUCKYRABBITSPIN.sol";

contract ForeignToken {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x222); // Dummy pair address
    }
}

contract MockRouter {
    function factory() public pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }

    function WETH() public pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract LUCKYRABBITSPIN_Test is Test {
    LUCKYRABBITSPIN public token;
    ForeignToken public foreignToken;

    address public owner = address(0x1);
    address payable public dev = payable(address(0x2));
    address public nonOwner = address(0x3);
    address public tokenContract;

    function setUp() public {
        vm.label(owner, "Owner");
        vm.label(dev, "Dev");
        vm.label(nonOwner, "NonOwner");

        // Mock Uniswap setup to avoid call to non-contract address
        MockFactory mockFactory = new MockFactory();
        vm.etch(
            address(0x1111111111111111111111111111111111111111),
            address(mockFactory).code
        );

        MockRouter mockRouter = new MockRouter();
        vm.etch(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(mockRouter).code
        );

        vm.startPrank(owner);
        token = new LUCKYRABBITSPIN();
        tokenContract = address(token);
        token.setNewDevAddress(dev);
        vm.stopPrank();

        foreignToken = new ForeignToken();
        foreignToken.mint(tokenContract, 100 ether);
    }

    function test_OwnerCanRescueForeignTokens() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        uint256 contractBalanceBefore = foreignToken.balanceOf(tokenContract);
        uint256 ownerBalanceBefore = foreignToken.balanceOf(owner);
        console.log("Token Contract Foreign Balance (before):", contractBalanceBefore);
        console.log("Owner Foreign Balance (before):", ownerBalanceBefore);

        console.log("--- Trigger Rescue (Owner) ---");
        vm.prank(owner);
        token.rescueForeignTokens(address(foreignToken), owner, 100 ether);

        console.log("--- AFTER-Trigger Rescue ---");
        uint256 contractBalanceAfter = foreignToken.balanceOf(tokenContract);
        uint256 ownerBalanceAfter = foreignToken.balanceOf(owner);
        console.log("Token Contract Foreign Balance (after):", contractBalanceAfter);
        console.log("Owner Foreign Balance (after):", ownerBalanceAfter);

        assertEq(foreignToken.balanceOf(owner), 100 ether, "Owner should receive the rescued tokens");
        assertEq(foreignToken.balanceOf(tokenContract), 0, "Token contract's balance should be drained");

        bool changeDetected = (contractBalanceAfter < contractBalanceBefore) && 
                              (ownerBalanceAfter > ownerBalanceBefore);
        require(changeDetected, "State change verification failed");
        console.log("Vulnerability not Exist: Owner rescue function works correctly");
    }

    function test_DevCanRescueForeignTokens() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        uint256 contractBalanceBefore = foreignToken.balanceOf(tokenContract);
        uint256 devBalanceBefore = foreignToken.balanceOf(dev);
        console.log("Token Contract Foreign Balance (before):", contractBalanceBefore);
        console.log("Dev Foreign Balance (before):", devBalanceBefore);

        console.log("--- Trigger Rescue (Dev) ---");
        vm.prank(dev);
        token.rescueForeignTokens(address(foreignToken), dev, 100 ether);

        console.log("--- AFTER-Trigger Rescue ---");
        uint256 contractBalanceAfter = foreignToken.balanceOf(tokenContract);
        uint256 devBalanceAfter = foreignToken.balanceOf(dev);
        console.log("Token Contract Foreign Balance (after):", contractBalanceAfter);
        console.log("Dev Foreign Balance (after):", devBalanceAfter);

        assertEq(foreignToken.balanceOf(dev), 100 ether, "Dev should receive the rescued tokens");
        assertEq(foreignToken.balanceOf(tokenContract), 0, "Token contract's balance should be drained");

        bool changeDetected = (contractBalanceAfter < contractBalanceBefore) && 
                              (devBalanceAfter > devBalanceBefore);
        require(changeDetected, "State change verification failed");
        console.log("Vulnerability not Exist: Dev rescue function works correctly");
    }

    function test_NonOwnerCannotRescueTokens() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        uint256 contractBalanceBefore = foreignToken.balanceOf(tokenContract);
        uint256 nonOwnerBalanceBefore = foreignToken.balanceOf(nonOwner);
        console.log("Token Contract Foreign Balance (before):", contractBalanceBefore);
        console.log("Non-Owner Foreign Balance (before):", nonOwnerBalanceBefore);

        console.log("--- Trigger Rescue (Non-Owner) ---");
        vm.prank(nonOwner);
        vm.expectRevert("Caller is not the dev");
        token.rescueForeignTokens(address(foreignToken), nonOwner, 100 ether);

        console.log("--- AFTER-Trigger Rescue ---");
        uint256 contractBalanceAfter = foreignToken.balanceOf(tokenContract);
        uint256 nonOwnerBalanceAfter = foreignToken.balanceOf(nonOwner);
        console.log("Token Contract Foreign Balance (after):", contractBalanceAfter);
        console.log("Non-Owner Foreign Balance (after):", nonOwnerBalanceAfter);

        assertEq(foreignToken.balanceOf(tokenContract), 100 ether, "Tokens should remain in contract");

        bool noChange = (contractBalanceAfter == contractBalanceBefore) && 
                        (nonOwnerBalanceAfter == nonOwnerBalanceBefore);
        require(noChange, "Unauthorized state change detected");
        console.log("Vulnerability not Exist: Access control prevents unauthorized rescue");
    }
}