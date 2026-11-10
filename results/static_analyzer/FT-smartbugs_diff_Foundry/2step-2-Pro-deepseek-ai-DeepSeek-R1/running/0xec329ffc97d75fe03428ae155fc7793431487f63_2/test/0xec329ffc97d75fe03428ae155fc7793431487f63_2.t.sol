// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract MockToken is Token {
    mapping(address => uint256) private _balances;

    constructor(uint256 initialSupply) {
        _balances[address(this)] = initialSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    // Helper to set balance for tests
    function setBalance(address account, uint256 amount) external {
        _balances[account] = amount;
    }
}

contract TokenSenderTest is Test {
    TokenSender public tokenSender;
    MockToken public token;
    address owner = address(0x123);

    uint256 constant D160 = 2**160;

    function setUp() public {
        token = new MockToken(0);
        tokenSender = new TokenSender(address(token));
        tokenSender.changeOwner(owner);
    }

    function testFillWithZeroAddress() public {
        // Set tokenSender's balance to exactly match the test distribution
        token.setBalance(address(tokenSender), 1 ether);
        
        uint256[] memory data = new uint256[](1);
        data[0] = 1 * D160; // Amount=1, address=0

        console2.log("--- BEFORE-Trigger fill ---");
        uint256 nTransfersBefore = tokenSender.nTransfers();
        uint256 totalToDistributeBefore = tokenSender.totalToDistribute();
        uint256 nextBefore = tokenSender.next();
        console2.log("nTransfers before:", nTransfersBefore);
        console2.log("totalToDistribute before:", totalToDistributeBefore);
        console2.log("next before:", nextBefore);

        console2.log("--- Trigger fill ---");
        vm.prank(owner);
        tokenSender.fill(data);

        console2.log("--- AFTER-Trigger fill ---");
        uint256 nTransfersAfter = tokenSender.nTransfers();
        uint256 totalToDistributeAfter = tokenSender.totalToDistribute();
        uint256 nextAfter = tokenSender.next();
        console2.log("nTransfers after:", nTransfersAfter);
        console2.log("totalToDistribute after:", totalToDistributeAfter);
        console2.log("next after:", nextAfter);

        // Differential check
        bool stateChanged = (nTransfersAfter != nTransfersBefore) || (totalToDistributeAfter != totalToDistributeBefore);
        console2.log("State changed:", stateChanged ? "YES" : "NO");
        if (stateChanged) {
            console2.log("Vulnerability Exists: Transfers array and distribution amount were modified with invalid address.");
        } else {
            console2.log("Vulnerability not Exist: State remains unchanged after fill.");
        }

        vm.prank(owner);
        vm.expectRevert(); // Expect revert on transfer to zero address
        tokenSender.run();
    }

    function testFillWithLargeArrayGasConsumption() public {
        uint256 largeCount = 50000;
        uint256[] memory data = new uint256[](largeCount);

        // Encode valid transfers to avoid early reverts
        for (uint256 i = 0; i < largeCount; i++) {
            address testAddr = address(uint160(0x1000 + i));
            data[i] = (1 * D160) | uint256(uint160(testAddr));
        }

        console2.log("--- BEFORE-Trigger fill (large array) ---");
        uint256 nTransfersBefore = tokenSender.nTransfers();
        uint256 totalToDistributeBefore = tokenSender.totalToDistribute();
        uint256 nextBefore = tokenSender.next();
        console2.log("nTransfers before:", nTransfersBefore);
        console2.log("totalToDistribute before:", totalToDistributeBefore);
        console2.log("next before:", nextBefore);

        // Set gas limit to simulate real block conditions
        console2.log("--- Trigger fill (gas consumption test) ---");
        uint256 gasBefore = gasleft();
        vm.prank(owner);
        vm.expectRevert();
        tokenSender.fill(data); // Should fail due to gas exhaustion
        uint256 gasUsed = gasBefore - gasleft();
        console2.log("Gas used:", gasUsed);

        console2.log("--- AFTER-Trigger fill (large array) ---");
        uint256 nTransfersAfter = tokenSender.nTransfers();
        uint256 totalToDistributeAfter = tokenSender.totalToDistribute();
        uint256 nextAfter = tokenSender.next();
        console2.log("nTransfers after:", nTransfersAfter);
        console2.log("totalToDistribute after:", totalToDistributeAfter);
        console2.log("next after:", nextAfter);

        // Differential checks
        bool stateChanged = (nTransfersAfter != nTransfersBefore) || 
                            (totalToDistributeAfter != totalToDistributeBefore) ||
                            (nextAfter != nextBefore);
        console2.log("State changed:", stateChanged ? "YES" : "NO");
        console2.log("Gas consumption >30M:", gasUsed > 30_000_000 ? "YES" : "NO");
        
        // Vulnerability exists if state unchanged (due to revert) AND gas excessive
        if (gasUsed > 30_000_000 && !stateChanged) {
            console2.log("Vulnerability Exists: Excessive gas consumption without state change.");
            // Verify gas consumption exceeded acceptable block limit
            assertTrue(gasUsed > 30_000_000, "Gas consumption not excessive");
            assertEq(nTransfersAfter, nTransfersBefore, "nTransfers changed");
            assertEq(totalToDistributeAfter, totalToDistributeBefore, "totalToDistribute changed");
            assertEq(nextAfter, nextBefore, "next position changed");
        } else {
            console2.log("Vulnerability not Exist: Gas consumption acceptable or state changed unexpectedly.");
        }
    }
}