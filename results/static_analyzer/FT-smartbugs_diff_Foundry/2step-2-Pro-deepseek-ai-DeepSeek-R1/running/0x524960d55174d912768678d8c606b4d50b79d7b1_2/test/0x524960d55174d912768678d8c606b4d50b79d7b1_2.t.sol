// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x524960d55174d912768678d8c606b4d50b79d7b1.sol";

contract GasGuzzler {
    function register(string calldata) public pure {
        // Minimal implementation
    }

    function transfer(address, uint256) public {
        // Infinite loop to consume all gas
        while (true) {
            // Burn gas with computationally heavy operations
            bytes32 hash = keccak256(abi.encode(block.timestamp));
        }
    }
}

contract Centra4Test is Test {
    Centra4 public centra;
    address constant fixedAddr = 0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a;
    GasGuzzler private guzzler;
    
    address c2 = 0xAa27f8C1160886aacba64B2319D8d5469ef2Af79;

    function setUp() public {
        centra = new Centra4();
        guzzler = new GasGuzzler();
        
        // Patch fixed address with GasGuzzler bytecode
        vm.etch(fixedAddr, address(guzzler).code);
    }

    function test_transferFailsDueToOutOfGas() public {
        // Snapshot state BEFORE transfer call
        console2.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalTransfersBefore = centra.totalTransfers();
        uint256 userTransferCountBefore = centra.userTransferCounts(address(this));
        console2.log("Initial totalTransfers:", totalTransfersBefore);
        console2.log("Initial userTransferCount:", userTransferCountBefore);

        // Trigger transfer operation (expected to fail)
        console2.log("--- Trigger Transfer ---");
        vm.expectEmit(true, true, false, true, address(centra));
        emit Centra4.TransferExecuted(address(this), c2, 1, false);
        bool result = centra.transfer();

        // Snapshot state AFTER transfer call
        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 totalTransfersAfter = centra.totalTransfers();
        uint256 userTransferCountAfter = centra.userTransferCounts(address(this));
        console2.log("Updated totalTransfers:", totalTransfersAfter);
        console2.log("Updated userTransferCount:", userTransferCountAfter);

        // Verification comparison
        bool totalChanged = totalTransfersAfter != totalTransfersBefore;
        bool userCountChanged = userTransferCountAfter != userTransferCountBefore;
        console2.log("totalTransfers changed?", totalChanged ? "YES" : "NO");
        console2.log("userTransferCount changed?", userCountChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (totalChanged || userCountChanged) {
            console2.log("Vulnerability Exists: State changed despite out-of-gas failure");
        } else {
            console2.log("Vulnerability not Exist: State remains unchanged after failure");
        }
    }
}