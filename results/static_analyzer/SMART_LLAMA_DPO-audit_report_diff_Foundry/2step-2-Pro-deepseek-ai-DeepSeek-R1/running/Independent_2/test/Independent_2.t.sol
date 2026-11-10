// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Independent.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract Independent_MultiTransfer_Test is Test {
    Independent token;
    address owner = address(0x1000);
    address alice = address(0x2000);
    address bob = address(0x3000);
    
    function setUp() public {
        address wbnbAddress = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        // Create and deploy mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), wbnbAddress);
        
        // Mock contract implementation at expected addresses
        vm.etch(routerAddress, address(mockRouter).code);
        vm.etch(wbnbAddress, new bytes(1)); // Dummy code
        
        vm.startPrank(owner);
        token = new Independent();
        token.manage_blacklist_status(false); // Disable blacklist
        token.tradingStatus(true); // Enable trading
        vm.stopPrank();
    }

    function test_MultiTransfer_DuplicateAddress() public {
        vm.startPrank(owner);
        
        // Get pre-transfer balances
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 transferAmount = ownerBalanceBefore / 30; // Safe fraction of total supply
        uint256 totalAmount = transferAmount * 3;

        require(
            ownerBalanceBefore >= totalAmount,
            "Owner doesn't have enough tokens"
        );

        // Log BEFORE state
        console.log("--- BEFORE-Trigger ---");
        console.log("Owner balance: ", ownerBalanceBefore);
        console.log("Alice balance: ", aliceBalanceBefore);
        console.log("Bob balance: ", bobBalanceBefore);

        // Create recipients array with duplicate alice address
        address[] memory recipients = new address[](3);
        recipients[0] = alice;
        recipients[1] = alice; // Duplicate
        recipients[2] = bob;

        // Create amounts array (two transfers to alice, one to bob)
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = transferAmount;
        amounts[1] = transferAmount;
        amounts[2] = transferAmount;

        console.log("--- Trigger MultiTransfer ---");
        // Execute multiTransfer with duplicate addresses
        token.multiTransfer(owner, recipients, amounts);
        console.log("Executed multiTransfer with duplicate Alice address");

        // Get post-transfer balances
        console.log("--- AFTER-Trigger ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        console.log("Owner balance: ", ownerBalanceAfter);
        console.log("Alice balance: ", aliceBalanceAfter);
        console.log("Bob balance: ", bobBalanceAfter);

        // Calculate & log balance changes
        console.log("Owner balance change: Expected %d, Actual %d", 
                    totalAmount, 
                    ownerBalanceBefore - ownerBalanceAfter);
        console.log("Alice balance change: Expected %d, Actual %d", 
                    2 * transferAmount, 
                    aliceBalanceAfter - aliceBalanceBefore);
        console.log("Bob balance change:   Expected %d, Actual %d", 
                    transferAmount, 
                    bobBalanceAfter - bobBalanceBefore);
        
        // Final vulnerability verdict
        if (aliceBalanceAfter - aliceBalanceBefore == 2 * transferAmount) {
            console.log("Vulnerability Exists: Contract allows duplicate addresses in multiTransfer, enabling multiple transfers to same address");
        } else {
            console.log("Vulnerability not Exist: Contract correctly handles duplicate addresses with expected behavior");
        }

        // Verify final balances with assertions
        assertEq(
            aliceBalanceAfter,
            aliceBalanceBefore + 2 * transferAmount,
            "Alice should have received duplicate transfers"
        );
        assertEq(
            bobBalanceAfter,
            bobBalanceBefore + transferAmount,
            "Bob should have received his transfer"
        );
        assertEq(
            ownerBalanceAfter,
            ownerBalanceBefore - totalAmount,
            "Owner balance should decrease by totalAmount"
        );
        vm.stopPrank();
    }
}