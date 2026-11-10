// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIVulnerabilityTest is Test {
    DEXI token;
    address owner;
    address mockPair = address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
    
    function setUp() public {
        token = new DEXI();
        owner = address(this);
    }

    function testDuplicatePairReverts() public {
        // Add initial pair
        token.addSwapPair(mockPair);
        assertTrue(token.isPoolPair(mockPair));
        
        // DIFF: Query pre-trigger state
        uint256 preLength = token.getPairsLength();
        emit log_named_uint("--- BEFORE-Trigger Pairs Length ---", preLength);
        
        // Trigger operation (expected to revert)
        emit log("--- Trigger AddSwapPair (expect revert) ---");
        vm.expectRevert("add: SwapV2Pair already added");
        token.addSwapPair(mockPair);
        
        // DIFF: Query post-trigger state
        uint256 postLength = token.getPairsLength();
        emit log_named_uint("--- AFTER-Trigger Pairs Length ---", postLength);
        
        // Validate state change
        if (preLength != postLength) {
            emit log("Vulnerability Exists: State changed despite revert");
        } else {
            emit log("Vulnerability not Exist: State unchanged by reverted call");
        }
    }
}