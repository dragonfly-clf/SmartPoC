// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BCPToken.sol";

contract MintAtomicityTest is Test {
    BCPToken public token;
    ERC20PresetMinterPauser public uncappedToken;
    address receiver = address(0x1);
    
    // Define expected ERC20 Transfer event
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        // Deploy capped token
        token = new BCPToken("CappedToken", "CPT", 1000);
        
        // Deploy uncapped token
        uncappedToken = new ERC20PresetMinterPauser("UncappedToken", "UPCT");
    }

    // Test: Ensure overflow protection works via SafeMath
    function test_MintRevertsOnOverflow() public {
        // Mint once to set non-zero total supply
        uncappedToken.mint(receiver, 1);
        
        // Attempt to mint an amount that would cause overflow
        uint256 overflowAmount = uint256(-1); // Max value in Solidity 0.6.2
        vm.expectRevert("SafeMath: addition overflow");
        uncappedToken.mint(receiver, overflowAmount);

        // Vulnerability check
        console.log("Vulnerability not Exist: SafeMath prevents overflow");
    }

    // Test: Verify Transfer event is properly emitted on mint
    function test_MintEmitsTransferEvent() public {
        uint256 amount = 100;

        // Test for capped token
        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(address(0), receiver, amount);
        token.mint(receiver, amount);
        
        // Test for uncapped token
        vm.expectEmit(true, true, false, true, address(uncappedToken));
        emit Transfer(address(0), receiver, amount);
        uncappedToken.mint(receiver, amount);

        // Vulnerability check
        console.log("Vulnerability not Exist: Transfer events emitted correctly");
    }
}