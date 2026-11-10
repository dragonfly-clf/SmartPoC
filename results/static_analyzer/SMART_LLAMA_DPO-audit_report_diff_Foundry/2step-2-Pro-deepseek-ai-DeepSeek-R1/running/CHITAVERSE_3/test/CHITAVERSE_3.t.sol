// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract CHITAVERSE_TransferFrom_Event_Test is Test {
    CHITAVERSE token;
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xA1);
    address constant MOCK_PAIR = address(0xB1);
    
    address owner = address(this); // Test contract as deployer
    address spender = address(0x1);
    address recipient = address(0x2);
    uint256 transferAmount = 1e18; // Reduced transfer amount

    function setUp() public {
        // Mock router factory() response
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock createPair response with any tokens
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(MOCK_PAIR)
        );
        
        // Deploy token - uses mocks internally
        token = new CHITAVERSE();
        
        // Configure environment
        token.setIsFeeExempt(owner, true);
        token.setIsFeeExempt(spender, true);
        token.setIsFeeExempt(recipient, true);
        token.isBots(spender, false);
        token.isBots(recipient, false);
        token.setTxLimit(type(uint256).max);
        token.setMaxWallet(type(uint256).max); // Added max wallet configuration
        vm.stopPrank();
        
        // Grant approval
        token.approve(spender, transferAmount);
    }

    function test_transferFrom_MissingTransferEvent() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Owner balance:", ownerBalanceBefore);
        console.log("Recipient balance:", recipientBalanceBefore);

        console.log("--- Trigger TransferFrom ---");
        // Execute transferFrom from spender account
        vm.prank(spender);
        token.transferFrom(owner, recipient, transferAmount);
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Owner balance:", ownerBalanceAfter);
        console.log("Recipient balance:", recipientBalanceAfter);
        
        // Validate state changes
        assertEq(
            token.balanceOf(owner),
            ownerBalanceBefore - transferAmount,
            "Owner balance mismatch"
        );
        assertEq(
            token.balanceOf(recipient),
            recipientBalanceBefore + transferAmount,
            "Recipient balance mismatch"
        );
        
        // Verify Transfer event existence
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 transferEventSig = keccak256("Transfer(address,address,uint256)");
        bool eventFound = false;
        
        for (uint256 i; i < logs.length; i++) {
            if (logs[i].topics[0] == transferEventSig) {
                eventFound = true;
                break;
            }
        }
        
        if (eventFound) {
            console.log("Vulnerability not Exist: Transfer event was correctly emitted");
        } else {
            console.log("Vulnerability Exists: Missing Transfer event during transferFrom");
        }
    }
}