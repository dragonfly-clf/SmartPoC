// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract GasOptimizationTest is Test {
    Log public logContract;
    address constant user = address(0x1);
    
    function setUp() public {
        logContract = new Log();
    }

    function testGasInefficiency() public {
        uint256 ABSOLUTE_THRESHOLD = 200000;
        uint256 DIFFERENTIAL_THRESHOLD = 20000;

        emit log("--- BEFORE-First AddMessage Call ---");
        uint256 gasBefore1 = gasleft();
        emit log_named_uint("Gas before first call", gasBefore1);
        
        logContract.AddMessage(user, 0.001 ether, "First message");
        uint256 gasCost1 = gasBefore1 - gasleft();
        emit log_named_uint("First call gas cost", gasCost1);

        emit log("--- BEFORE-Second AddMessage Call ---");
        uint256 gasBefore2 = gasleft();
        emit log_named_uint("Gas before second call", gasBefore2);
        
        logContract.AddMessage(user, 0.002 ether, "Second message");
        uint256 gasCost2 = gasBefore2 - gasleft();
        emit log_named_uint("Second call gas cost", gasCost2);

        bool vulnerable = false;
        string memory reason = "all gas costs within expected thresholds";
        
        emit log("--- Vulnerability Analysis ---");
        string memory msg1 = string.concat(
            "Absolute gas limit: ", 
            vm.toString(ABSOLUTE_THRESHOLD),
            " | First call: ", 
            vm.toString(gasCost1)
        );
        emit log(msg1);
        
        string memory msg2 = string.concat(
            "Absolute gas limit: ", 
            vm.toString(ABSOLUTE_THRESHOLD),
            " | Second call: ", 
            vm.toString(gasCost2)
        );
        emit log(msg2);
        
        int256 diff = int256(gasCost2) - int256(gasCost1);
        emit log_named_int("Differential threshold vs actual", diff);
        emit log_named_uint("Allowed differential threshold", DIFFERENTIAL_THRESHOLD);

        if (gasCost1 > ABSOLUTE_THRESHOLD) {
            vulnerable = true;
            reason = "first call exceeds gas threshold (200,000)";
        } else if (gasCost2 > ABSOLUTE_THRESHOLD) {
            vulnerable = true;
            reason = "second call exceeds gas threshold (200,000)";
        } else if (gasCost2 > gasCost1) {
            uint256 increase = gasCost2 - gasCost1;
            if (increase > DIFFERENTIAL_THRESHOLD) {
                vulnerable = true;
                reason = "gas cost increased more than allowed (exceeds 20,000 increase)";
            }
        }

        if (vulnerable) {
            emit log(string(abi.encodePacked("Vulnerability Exists: ", reason)));
        } else {
            emit log(string(abi.encodePacked("Vulnerability not Exist: ", reason)));
        }
    }
}