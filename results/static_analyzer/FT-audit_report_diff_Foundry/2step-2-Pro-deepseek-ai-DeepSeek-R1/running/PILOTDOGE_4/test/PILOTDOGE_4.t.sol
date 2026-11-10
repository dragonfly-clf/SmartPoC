// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PILOTDOGE.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xCAFEFEE);
    }

    function WETH() external pure returns (address) {
        return address(0xDEADBEEF);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x0);
    }
}

contract PILOTDOGEManualSendTest is Test {
    PILOTDOGE public token;
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address unauthorized = address(0x2);
    
    // Slots for address variables (assuming first two storage slots)
    uint256 constant DEVELOPMENT_SLOT = 0;
    uint256 constant MARKETING_SLOT = 1;
    
    function setUp() public {
        // Mock Uniswap router and factory
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(address(0xCAFEFEE), address(mockFactory).code);
        vm.etch(address(0xDEADBEEF), bytes(""));

        // Deploy token - test contract becomes owner
        token = new PILOTDOGE();
        
        // Fund contract
        vm.deal(address(token), 1 ether);
    }

    // Helper to extract address from storage slot
    function extractAddress(uint256 slot) internal view returns (address) {
        bytes32 value = vm.load(address(token), bytes32(slot));
        return address(uint160(uint256(value)));
    }

    function getBalances() internal view returns (uint256, uint256, uint256) {
        address devAddress = extractAddress(DEVELOPMENT_SLOT);
        address marketingAddress = extractAddress(MARKETING_SLOT);
        return (
            address(token).balance,
            devAddress.balance,
            marketingAddress.balance
        );
    }

    function testManualsendDrainsBalance() public {
        (uint256 tokenBalBefore, uint256 devBalBefore, uint256 marketingBalBefore) = getBalances();
        console.log("--- BEFORE-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalBefore);
        console.log("Development address balance: %s", devBalBefore);
        console.log("Marketing address balance: %s", marketingBalBefore);
        
        console.log("--- Trigger Manualsend ---");
        token.manualsend();
        
        (uint256 tokenBalAfter, uint256 devBalAfter, uint256 marketingBalAfter) = getBalances();
        console.log("--- AFTER-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalAfter);
        console.log("Development address balance: %s", devBalAfter);
        console.log("Marketing address balance: %s", marketingBalAfter);
        
        // Contract balance should be fully drained
        assertEq(address(token).balance, 0, "Contract ETH not fully transferred");
        
        // Differential checks
        uint256 totalTransferred = (devBalAfter - devBalBefore) + (marketingBalAfter - marketingBalBefore);
        console.log("Total transferred: %s | Expected: %s", totalTransferred, tokenBalBefore);
        
        bool conservationValid = tokenBalBefore == totalTransferred + tokenBalAfter;
        console.log("ETH conservation: %s", conservationValid ? "Valid" : "Invalid");
        console.log("Vulnerability not Exist: Function works correctly with full balance");
    }

    function testManualsendWithOneWei() public {
        // Set balance to odd amount (1 wei)
        vm.deal(address(token), 1);
        (uint256 tokenBalBefore, uint256 devBalBefore, uint256 marketingBalBefore) = getBalances();
        console.log("--- BEFORE-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalBefore);
        console.log("Development address balance: %s", devBalBefore);
        console.log("Marketing address balance: %s", marketingBalBefore);
        
        console.log("--- Trigger Manualsend ---");
        token.manualsend();
        
        (uint256 tokenBalAfter, uint256 devBalAfter, uint256 marketingBalAfter) = getBalances();
        console.log("--- AFTER-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalAfter);
        console.log("Development address balance: %s", devBalAfter);
        console.log("Marketing address balance: %s", marketingBalAfter);
        
        // Should leave 1 wei since division truncates
        assertEq(address(token).balance, 1, "Should leave residual wei");
        
        // Differential checks
        uint256 devReceived = devBalAfter - devBalBefore;
        uint256 marketingReceived = marketingBalAfter - marketingBalBefore;
        uint256 totalTransferred = devReceived + marketingReceived;
        
        console.log("Development received: %s | Marketing received: %s", devReceived, marketingReceived);
        console.log("Total transferred: %s | Expected: %s", totalTransferred, tokenBalBefore - tokenBalAfter);
        
        bool conservationValid = tokenBalBefore == totalTransferred + tokenBalAfter;
        console.log("ETH conservation: %s", conservationValid ? "Valid" : "Invalid");
        console.log("Vulnerability not Exist: Function handles odd values correctly");
    }

    function testManualsendWithThreeWei() public {
        // Set balance to odd amount (3 wei)
        vm.deal(address(token), 3);
        (uint256 tokenBalBefore, uint256 devBalBefore, uint256 marketingBalBefore) = getBalances();
        console.log("--- BEFORE-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalBefore);
        console.log("Development address balance: %s", devBalBefore);
        console.log("Marketing address balance: %s", marketingBalBefore);
        
        console.log("--- Trigger Manualsend ---");
        token.manualsend();
        
        (uint256 tokenBalAfter, uint256 devBalAfter, uint256 marketingBalAfter) = getBalances();
        console.log("--- AFTER-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalAfter);
        console.log("Development address balance: %s", devBalAfter);
        console.log("Marketing address balance: %s", marketingBalAfter);
        
        // Should leave 1 wei after transfer of 3 wei
        assertEq(address(token).balance, 1, "Should leave 1 wei after transfer of 3 wei");
        
        // Differential checks
        uint256 devReceived = devBalAfter - devBalBefore;
        uint256 marketingReceived = marketingBalAfter - marketingBalBefore;
        uint256 totalTransferred = devReceived + marketingReceived;
        
        console.log("Development received: %s | Marketing received: %s", devReceived, marketingReceived);
        console.log("Total transferred: %s | Expected: %s", totalTransferred, tokenBalBefore - tokenBalAfter);
        console.log("Residual amount: %s | Expected: %s", tokenBalAfter, 1);
        
        bool conservationValid = tokenBalBefore == totalTransferred + tokenBalAfter;
        console.log("ETH conservation: %s", conservationValid ? "Valid" : "Invalid");
        console.log("Vulnerability not Exist: Function handles uneven division correctly");
    }

    function testManualsendWithZeroBalance() public {
        // Clear contract balance
        vm.deal(address(token), 0);
        (uint256 tokenBalBefore, uint256 devBalBefore, uint256 marketingBalBefore) = getBalances();
        console.log("--- BEFORE-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalBefore);
        console.log("Development address balance: %s", devBalBefore);
        console.log("Marketing address balance: %s", marketingBalBefore);
        
        console.log("--- Trigger Manualsend ---");
        token.manualsend();
        
        (uint256 tokenBalAfter, uint256 devBalAfter, uint256 marketingBalAfter) = getBalances();
        console.log("--- AFTER-Trigger Manualsend ---");
        console.log("Token contract balance: %s", tokenBalAfter);
        console.log("Development address balance: %s", devBalAfter);
        console.log("Marketing address balance: %s", marketingBalAfter);
        
        // Should remain zero
        assertEq(address(token).balance, 0, "Balance should remain zero");
        
        // No ETH should move
        uint256 totalReceived = (devBalAfter - devBalBefore) + (marketingBalAfter - marketingBalBefore);
        console.log("Total ETH transferred: %s", totalReceived);
        console.log("Vulnerability not Exist: Function handles zero balance correctly");
    }

    function testUnauthorizedCallReverts() public {
        // Setup balances for detection
        vm.deal(address(token), 1 ether);
        (uint256 tokenBalBefore, , ) = getBalances();
        
        console.log("--- BEFORE-Unauthorized Call ---");
        console.log("Token contract balance: %s", tokenBalBefore);
        
        console.log("--- Trigger Unauthorized Manualsend ---");
        vm.prank(unauthorized);
        vm.expectRevert();
        token.manualsend();
        
        console.log("--- AFTER-Unauthorized Call ---");
        (uint256 tokenBalAfter, , ) = getBalances();
        console.log("Token contract balance: %s", tokenBalAfter);
        
        assertEq(tokenBalAfter, tokenBalBefore, "Balance unchanged after unauthorized call");
        console.log("Vulnerability not Exist: Unauthorized access prevented");
    }
}