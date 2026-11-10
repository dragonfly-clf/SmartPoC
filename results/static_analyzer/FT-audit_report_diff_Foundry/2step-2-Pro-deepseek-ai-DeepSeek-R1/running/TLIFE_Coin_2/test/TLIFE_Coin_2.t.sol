// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TLIFE_Coin.sol";

contract TLIFE_Coin_Test is Test {
    TLIFE_Coin token;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1000000 ether;

    function setUp() public {
        // Deploy TLIFE_Coin with owner's privileges using vm.deal for msg.value
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        token = new TLIFE_Coin{value: 1 ether}(
            attacker,          // __TLIFEcrypt_target
            "TestToken",       // __TLIFEcrypt_name
            "TT",              // __TLIFEcrypt_symbol
            DECIMALS,          // __TLIFEcrypt_decimals
            INITIAL_SUPPLY     // __TLIFEcrypt_initial
        );
    }

    // Test to verify proper isolation of ownership contexts
    function testCannotTransferOwnershipThroughMaliciousContract() public {
        console2.log("--- BEFORE-Trigger Owner ---");
        address ownerBefore = token.owner();
        console2.log("Owner address before attack:", ownerBefore);

        // Deploy malicious contract
        MaliciousContract mc = new MaliciousContract(address(token));
        
        console2.log("--- Trigger Attack ---");
        vm.prank(owner);
        vm.expectRevert("ERC20Ownable: caller is not the owner");
        mc.attack(attacker);

        console2.log("--- AFTER-Trigger Owner ---");
        address ownerAfter = token.owner();
        console2.log("Owner address after attack:", ownerAfter);

        // Vulnerability verdict based on ownership change
        if (ownerBefore != ownerAfter) {
            console2.log("Vulnerability Exists: Ownership was changed to attacker");
        } else {
            console2.log("Vulnerability not Exist: Ownership remains unchanged");
        }
        
        // Final vulnerability verdict (single console output)
        if (ownerBefore != ownerAfter) {
            console2.log("Vulnerability Exists: Ownership changed without authorization");
        } else {
            console2.log("Vulnerability not Exist: Ownership remains secure");
        }

        // Original assertion for ownership
        assertEq(token.owner(), owner, "Ownership should remain with original owner");
    }
}

contract MaliciousContract {
    TLIFE_Coin token;

    constructor(address _token) {
        token = TLIFE_Coin(_token);
    }

    function attack(address _attacker) public {
        token.transferOwnership(_attacker);
    }
}