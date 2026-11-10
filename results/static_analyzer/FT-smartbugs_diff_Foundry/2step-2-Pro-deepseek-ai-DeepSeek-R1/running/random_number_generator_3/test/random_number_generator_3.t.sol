// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract RandomNumberGeneratorTest is Test {
    RandomNumberGenerator public rng;

    function setUp() public {
        rng = new RandomNumberGenerator();
    }

    function test_randomFunctionOverflow() public {
        // Set salt to MAX_UINT256 - 3 (ensures non-zero modulo 5)
        uint256 hugeSalt = type(uint256).max - 3;
        vm.store(address(rng), bytes32(uint256(0)), bytes32(hugeSalt));

        // Set high block number to cause overflow
        vm.roll(100000000);

        // Pre-trigger setup snapshot
        console.log("--- BEFORE-Trigger Setup ---");
        console.log("Salt set to: %s", hugeSalt);
        console.log("Block.number set to: %s", block.number);

        // Trigger operation
        console.log("--- Trigger playGame ---");
        vm.recordLogs();
        rng.playGame(1);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Extract and validate event
        console.log("--- AFTER-Trigger Result ---");
        bool eventFound;
        uint256 randomResult;
        bytes32 winningNumberEvent = keccak256("WinningNumberSet(uint256)");
        
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].topics[0] == winningNumberEvent) {
                randomResult = abi.decode(entries[i].data, (uint256));
                eventFound = true;
                console.log("Event emitted with randomResult: %s", randomResult);
                break;
            }
        }

        if (!eventFound) {
            console.log("Vulnerability not Exist: WinningNumberSet event not emitted");
            return;
        }

        if (randomResult >= 1 && randomResult <= 100) {
            console.log("Vulnerability Exists: Overflow vulnerability executed without revert and produced valid random number");
        } else {
            console.log("Vulnerability not Exist: Random result out of expected bounds [1,100]");
        }
    }

    function test_randomFunctionDivisionByZero() public {
        // Set salt to 5 to cause salt % 5 = 0
        vm.store(address(rng), bytes32(uint256(0)), bytes32(uint256(5)));
        
        // Pre-trigger setup snapshot
        console.log("--- BEFORE-Trigger Setup ---");
        console.log("Salt set to: 5");

        // Trigger operation and catch the revert reason
        console.log("--- Trigger playGame ---");
        try rng.playGame(1) {
            console.log("--- AFTER-Trigger Result ---");
            console.log("Transaction did not revert");
            console.log("Vulnerability not Exist: Division by zero did not occur");
        } catch Error(string memory reason) {
            bytes32 errHash = keccak256(bytes(reason));
            if (errHash == keccak256(bytes(stdError.divisionError))) {
                console.log("--- AFTER-Trigger Result ---");
                console.log("Transaction reverted with divisionError");
                console.log("Vulnerability Exists: Division by zero triggered as expected");
            } else {
                console.log("--- AFTER-Trigger Result ---");
                console.log("Transaction reverted with error: %s", reason);
                console.log("Vulnerability not Exist: Division by zero did not occur; got unexpected reason");
            }
        } catch (bytes memory) {
            console.log("--- AFTER-Trigger Result ---");
            console.log("Transaction reverted with low-level exception");
            console.log("Vulnerability not Exist: Division by zero did not trigger as a String error");
        }
    }
}