// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaeggDeFi.sol";

contract MetaeggDeFiTest is Test {
    MetaeggDeFi token;
    address internal constant INVALID_ADDRESS = address(0);
    address internal owner;

    function setUp() public {
        owner = address(this);
        token = new MetaeggDeFi();
        token.mint(owner, 1000 ether);
    }

    // Test vulnerable token transfer to invalid address
    function testTransferToInvalidAddress() public {
        emit log("--- BEFORE-Trigger Transfer ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 invalidBalanceBefore = token.balanceOf(INVALID_ADDRESS);
        emit log_named_uint("Owner balance before", ownerBalanceBefore);
        emit log_named_uint("Invalid address balance before", invalidBalanceBefore);

        emit log("--- Trigger Transfer to Invalid Address ---");
        // Attempt to transfer tokens to null address
        vm.expectRevert();
        token.transfer(INVALID_ADDRESS, 100 ether);
        
        // Alternative check using call syntax
        emit log("--- Execute Low-level Call Transfer ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                token.transfer.selector,
                INVALID_ADDRESS,
                100 ether
            )
        );
        emit log_named_string("Low-level call success", success ? "true" : "false");

        emit log("--- AFTER-Trigger Transfer ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 invalidBalanceAfter = token.balanceOf(INVALID_ADDRESS);
        emit log_named_uint("Owner balance after", ownerBalanceAfter);
        emit log_named_uint("Invalid address balance after", invalidBalanceAfter);

        // Verify balances remain unchanged
        bool ownerBalanceUnchanged = (ownerBalanceAfter == ownerBalanceBefore);
        bool invalidBalanceUnchanged = (invalidBalanceAfter == invalidBalanceBefore);
        bool stateUnchanged = ownerBalanceUnchanged && invalidBalanceUnchanged;
        
        emit log_named_string("State unchanged", stateUnchanged ? "YES" : "NO");
        emit log_named_string("Transfer success", success ? "YES" : "NO");

        // Final vulnerability verdict
        if (success || !stateUnchanged) {
            emit log("Vulnerability Exists: Transfer to address(0) affected token balances");
        } else {
            emit log("Vulnerability not Exist: Transfer to address(0) was properly reverted");
        }
    }
}