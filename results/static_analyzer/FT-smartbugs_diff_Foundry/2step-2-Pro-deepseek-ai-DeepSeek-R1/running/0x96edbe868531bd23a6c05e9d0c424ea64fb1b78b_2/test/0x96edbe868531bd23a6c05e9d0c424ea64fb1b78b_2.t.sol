// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract PennyByPennyMinSumTest is Test {
    PENNY_BY_PENNY pennyContract;
    LogFile logFile;
    address user = makeAddr("user");
    
    function setUp() public {
        vm.deal(user, 1 ether); // Fund user
        
        // Create and set required LogFile contract
        logFile = new LogFile();
        pennyContract = new PENNY_BY_PENNY();
        pennyContract.SetLogFile(address(logFile));
    }

    function testCollectFailsWithoutSettingMinSum() public {
        uint depositAmount = 0.5 ether;
        uint withdrawAmount = 0.5 ether;
        
        // Deposit with no lock time
        vm.prank(user);
        pennyContract.Put{value: depositAmount}(0);
        
        console.log("--- BEFORE-Trigger Collect ---");
        uint userBalanceBefore = user.balance;
        uint contractBalanceBefore = address(pennyContract).balance;
        console.log("User balance before:      ", userBalanceBefore);
        console.log("Contract balance before:  ", contractBalanceBefore);
        
        console.log("--- Trigger Collect ---");
        vm.startPrank(user);
        (bool success, ) = address(pennyContract).call(abi.encodeWithSelector(pennyContract.Collect.selector, withdrawAmount));
        vm.stopPrank();
        console.log("Collect call result:      ", success ? "SUCCESS" : "FAIL");
        
        console.log("--- AFTER-Trigger Collect ---");
        uint userBalanceAfter = user.balance;
        uint contractBalanceAfter = address(pennyContract).balance;
        console.log("User balance after:       ", userBalanceAfter);
        console.log("Contract balance after:   ", contractBalanceAfter);
        
        bool balancesUnchanged = (userBalanceAfter == userBalanceBefore) && 
                                 (contractBalanceAfter == contractBalanceBefore);
        
        if (balancesUnchanged) {
            console.log("Vulnerability not Exist: Collect fails without MinSum set as expected");
        } else {
            console.log("Vulnerability Exists: Collect call succeeded without MinSum set");
        }
        
        assert(balancesUnchanged);
    }
}