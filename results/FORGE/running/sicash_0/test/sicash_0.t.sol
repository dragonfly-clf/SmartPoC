// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SitoCash.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return 0x1234567890123456789012345678901234567890;
    }

    function WETH() external pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract SitoCashMaxWalletTest is Test {
    SitoCash token;
    address constant ROUTER_ADDR = 0x509c97d4A7b98C91f1264304f228e3639416F118;
    address constant FACTORY_ADDR = 0x1234567890123456789012345678901234567890;
    address owner = address(0xA);
    address user1 = address(0xB);
    address user2 = address(0xC);
    
    function setUp() public {
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.etch(FACTORY_ADDR, address(mockFactory).code);
        
        vm.startPrank(owner);
        token = new SitoCash(owner);
        token.transfer(user1, 100 * 10**uint256(token.decimals()));
        vm.stopPrank();
    }
    
    function testMaxWalletZeroFreeze() public {
        uint256 decimals = token.decimals();
        uint256 amount = 10 * 10**decimals;

        console.log("--- BEFORE-Trigger State ---");
        uint256 initialMaxWallet = token.maxWalletToken();
        uint256 initialRecipientBalance = token.balanceOf(user2);
        console.log("Initial max wallet token limit:", initialMaxWallet);
        console.log("Initial recipient balance:", initialRecipientBalance);

        // Verify initial transfer works
        vm.prank(user1);
        token.transfer(user2, amount);
        uint256 afterTransferRecipientBalance = token.balanceOf(user2);
        console.log("First transfer complete - recipient balance:", afterTransferRecipientBalance);
        require(
            afterTransferRecipientBalance > initialRecipientBalance,
            "Recipient balance should increase"
        );

        console.log("--- Trigger: setMaxWalletTokens(0) ---");
        vm.prank(owner);
        token.setMaxWalletTokens(0);

        console.log("--- AFTER-Trigger State ---");
        uint256 newMaxWallet = token.maxWalletToken();
        uint256 preAttemptBalance = token.balanceOf(user2);
        console.log("New max wallet token limit:", newMaxWallet);
        console.log("Recipient balance before second transfer:", preAttemptBalance);

        // Verify transfer fails
        vm.prank(user1);
        try token.transfer(user2, amount) {
            fail("Transfer unexpectedly succeeded");
        } catch Error(string memory reason) {
            assertEq(reason, "Exceeds maximum wallet token amount.");
        }

        uint256 postAttemptBalance = token.balanceOf(user2);
        console.log("Recipient balance after failed transfer attempt:", postAttemptBalance);

        // Final vulnerability verdict
        bool stateChanged = (newMaxWallet == 0);
        bool balanceUnchanged = (preAttemptBalance == postAttemptBalance);
        bool exploitSuccessful = stateChanged && balanceUnchanged;
        
        if(exploitSuccessful) {
            console.log("Vulnerability Exists: Owner successfully set limit to 0 and froze transfers");
        } else {
            console.log("Vulnerability not Exist: Failed to freeze transfers after setting limit to 0");
        }
    }

    function testOwnerCanStillTransfer() public {
        uint256 decimals = token.decimals();
        uint256 amount = 10 * 10**decimals;
        
        // Set max wallet to zero
        vm.prank(owner);
        token.setMaxWalletTokens(0);
        
        // Owner transfers to user2
        uint256 initialBalance = token.balanceOf(user2);
        vm.prank(owner);
        token.transfer(user2, amount);
        
        // Verify transfer succeeded
        uint256 finalBalance = token.balanceOf(user2);
        assertEq(finalBalance, initialBalance + amount, "Transfer should be successful");
    }
}