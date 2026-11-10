// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe09b1ab8111c2729a76f16de96bc86a7af837928.sol";

contract MockWhale {
    bool public shouldFail;

    constructor(bool _shouldFail) {
        shouldFail = _shouldFail;
    }

    // Function to simulate donation failure
    function donate() external payable {
        if (shouldFail) {
            revert("Donation failed");
        }
    }
}

contract FiftyFlipTest is Test {
    FiftyFlip fiftyFlip;
    MockWhale failingWhale;
    address autoPlayBot = address(0x123);
    address secretSigner;
    uint256 privateKey;

    uint constant AMOUNT = 1 ether;

    function setUp() public {
        // Create failing whale contract
        failingWhale = new MockWhale(true);
        
        // Generate signer address
        privateKey = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        secretSigner = vm.addr(privateKey);

        // Deploy FiftyFlip with failing whale
        fiftyFlip = new FiftyFlip(
            address(failingWhale),
            autoPlayBot,
            secretSigner
        );

        // Fund contract to pass collateral check
        payable(address(fiftyFlip)).transfer(2 ether);
        
        // Fund test contract
        vm.deal(address(this), AMOUNT);
    }

    function testUncheckedCallVulnerability() public {
        uint ticketID = 1;
        uint ticketLastBlock = block.number + 100;

        // Create valid signature
        bytes32 message = keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n37',
                uint40(ticketLastBlock),
                ticketID
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        // Record initial state
        uint initialTotalToWhale = fiftyFlip.totalAmountToWhale();
        
        console.log("--- BEFORE Trigger ---");
        console.log("Initial totalAmountToWhale:", initialTotalToWhale);
        
        console.log("--- Trigger Wager Call ---");
        // Place wager - should succeed despite donation failure
        fiftyFlip.wager{value: AMOUNT}(true, ticketID, ticketLastBlock, v, r, s);

        // Verify state changed despite failed call
        uint finalTotalToWhale = fiftyFlip.totalAmountToWhale();
        
        console.log("--- AFTER Trigger ---");
        console.log("Final totalAmountToWhale:", finalTotalToWhale);
        
        // Vulnerability check
        if (finalTotalToWhale > initialTotalToWhale) {
            console.log("Vulnerability Exists: totalAmountToWhale increased despite donation failure");
        } else {
            console.log("Vulnerability not Exist: totalAmountToWhale unchanged after failed donation");
        }
    }
}