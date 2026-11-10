// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ApocalypseLand.sol";

contract ApocalypseLandTest is Test {
    ApocalypseLand token;
    address owner = address(0xCD);
    uint256 constant SLOT_AUTHNUM = 4; // Storage slot for _authNum
    
    function setUp() public {
        vm.startPrank(owner);
        token = new ApocalypseLand();
        vm.stopPrank();
    }

    function test_setAuth_DoesNotResetAuthNum() public {
        // Write to _authNum storage slot directly
        bytes32 authNumSlot = bytes32(SLOT_AUTHNUM);
        vm.store(address(token), authNumSlot, bytes32(uint256(123)));

        // Verify storage manipulation and snapshot state
        uint256 initialAuthNum = uint256(vm.load(address(token), authNumSlot));
        require(initialAuthNum == 123, "Initial setup failed");
        
        console.log("--- BEFORE-Trigger AuthNum ---");
        console.log("_authNum state:", initialAuthNum);

        console.log("--- Trigger setAuth ---");
        // Set new authentication addresses
        address newAuth1 = address(0x1);
        address newAuth2 = address(0x2);
        vm.prank(owner);
        token.setAuth(newAuth1, newAuth2);

        console.log("--- AFTER-Trigger AuthNum ---");
        // Verify _authNum was not reset
        uint256 updatedAuthNum = uint256(vm.load(address(token), authNumSlot));
        console.log("_authNum state:", updatedAuthNum);
        
        // Compare state and determine vulnerability existence
        if (updatedAuthNum == initialAuthNum) {
            console.log("DIFFERENTIAL VERDICT: State unchanged - Vulnerability exists");
            console.log("Vulnerability Exists: _authNum persists despite setAuth operation");
        } else {
            console.log("DIFFERENTIAL VERDICT: State changed - Vulnerability fixed");
            console.log("Vulnerability not Exist: _authNum correctly reset during setAuth");
        }
    }
}