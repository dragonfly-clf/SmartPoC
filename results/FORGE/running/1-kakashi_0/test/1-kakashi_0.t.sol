// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/KAKASHISENSEI.sol";

contract KakashiSenseiTest is Test {
    KAKASHISENSEI token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockFactory = address(0x1234567890123456789012345678901234567890);
    address mockPair = address(0xABC);
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Helper for token amount conversion
    function tokenAmount(uint256 amount) internal view returns (uint256) {
        return amount * 10**uint256(token.decimals());
    }

    function setUp() public {
        // Mock Uniswap router and factory calls
        vm.mockCall(
            mockRouter, 
            abi.encodeWithSignature("factory()"), 
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockFactory, 
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token and fund test addresses
        vm.startPrank(owner);
        token = new KAKASHISENSEI();
        token.transfer(alice, 1000 * 10**uint256(token.decimals()));
        vm.stopPrank();
    }

    function testMaxTxStopTransactions() public {
        // Disable antibot to enable pre-trigger transfers
        vm.prank(owner);
        token.turnOffAntibotMode();
        
        uint256 amount = tokenAmount(1);

        console2.log("--- BEFORE-Trigger MaxTxAmount ---");
        uint256 maxTxAmountBefore = token._maxTxAmount();
        uint256 aliceBalBefore = token.balanceOf(alice);
        uint256 bobBalBefore = token.balanceOf(bob);
        console2.log("MaxTxAmount: ", maxTxAmountBefore);
        console2.log("Alice balance: ", aliceBalBefore);
        console2.log("Bob balance: ", bobBalBefore);

        // Perform pre-trigger transfer (should succeed)
        console2.log("Performing pre-tx transfer...");
        vm.prank(alice);
        token.transfer(bob, amount);

        // Capture balances after successful pre-transfer
        uint256 aliceBalAfterPreTx = token.balanceOf(alice);
        uint256 bobBalAfterPreTx = token.balanceOf(bob);
        console2.log("Post-transfer Alice balance: ", aliceBalAfterPreTx);
        console2.log("Post-transfer Bob balance: ", bobBalAfterPreTx);
        console2.log("Alice balance delta: ", aliceBalBefore - aliceBalAfterPreTx);
        console2.log("Bob balance delta: ", bobBalAfterPreTx - bobBalBefore);
        
        console2.log("--- Trigger ChangeMaxTxPercent ---");
        // Critical action: Disable transfers
        vm.startPrank(owner);
        token.setMaxTxPercent(0); // Set to 0%
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger MaxTxAmount ---");
        uint256 maxTxAmountAfter = token._maxTxAmount();
        aliceBalAfterPreTx = token.balanceOf(alice); // Update values after state change
        bobBalAfterPreTx = token.balanceOf(bob);
        console2.log("MaxTxAmount: ", maxTxAmountAfter);
        console2.log("Alice balance: ", aliceBalAfterPreTx);
        console2.log("Bob balance: ", bobBalAfterPreTx);
        
        // Attempt same transfer (should fail)
        console2.log("Attempting same transfer post-trigger...");
        vm.prank(alice);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(bob, amount);
        
        console2.log("--- Differential Verification ---");
        // Capture final state
        uint256 aliceBalFinal = token.balanceOf(alice);
        uint256 bobBalFinal = token.balanceOf(bob);
        console2.log("Alice balance change:", aliceBalAfterPreTx - aliceBalFinal);
        console2.log("Bob balance change:", bobBalFinal - bobBalAfterPreTx);
        
        // Verify (any non-zero maxTxAmount change with transfer failure indicates vulnerability)
        bool vulnerabilityExists = (maxTxAmountAfter < maxTxAmountBefore) && 
            (aliceBalFinal == aliceBalAfterPreTx) && 
            (bobBalFinal == bobBalAfterPreTx);
            
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Setting maxTxPercent to 0 by owner successfully blocks transactions.");
        } else {
            console2.log("Vulnerability not Exist: Transactions not blocked after maxTxPercent set to 0.");
        }
    }

    // ... (other tests remain unchanged) ...
}