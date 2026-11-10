// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowMappingSym1 public overflowContract;
    
    function setUp() public {
        overflowContract = new IntegerOverflowMappingSym1();
    }

    function testInitialUnderflow() public {
        uint256 key = 1;
        uint256 initialValue = 100;
        
        console2.log("--- BEFORE-Trigger init ---");
        uint256 mapValueBefore = overflowContract.getMapValue(key);
        uint256 userOpCountBefore = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountBefore = overflowContract.totalOperations();
        uint256 lastOpTimeBefore = overflowContract.lastOperationTime();
        
        console2.log("Map value before:", mapValueBefore);
        console2.log("User operation count before:", userOpCountBefore);
        console2.log("Total operations before:", totalOpCountBefore);
        console2.log("Last operation time before:", lastOpTimeBefore);

        console2.log("--- Trigger init ---");
        overflowContract.init(key, initialValue);
        
        console2.log("--- AFTER-Trigger init ---");
        uint256 mapValueAfter = overflowContract.getMapValue(key);
        uint256 userOpCountAfter = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountAfter = overflowContract.totalOperations();
        uint256 lastOpTimeAfter = overflowContract.lastOperationTime();
        uint256 blockTimestamp = block.timestamp;
        
        console2.log("Map value after:", mapValueAfter);
        console2.log("User operation count after:", userOpCountAfter);
        console2.log("Total operations after:", totalOpCountAfter);
        console2.log("Last operation time after:", lastOpTimeAfter);
        console2.log("Current block timestamp:", blockTimestamp);

        bool underflowOccurred = mapValueAfter > type(uint256).max - initialValue;
        bool opCountIncreased = userOpCountAfter == userOpCountBefore + 1;
        bool totalOpCountIncreased = totalOpCountAfter == totalOpCountBefore + 1;
        bool timeUpdated = lastOpTimeAfter == blockTimestamp;

        console2.log("Integer underflow occurred?", underflowOccurred ? "YES" : "NO");
        console2.log("User op count increased?", opCountIncreased ? "YES" : "NO");
        console2.log("Total op count increased?", totalOpCountIncreased ? "YES" : "NO");
        console2.log("Last op time updated?", timeUpdated ? "YES" : "NO");

        if (underflowOccurred) {
            console2.log("Vulnerability Exists: Integer underflow occurred in mapping value");
        } else {
            console2.log("Vulnerability not Exist: No integer underflow occurred");
        }
    }

    function testSubsequentUnderflow() public {
        uint256 key = 2;
        uint256 firstValue = 100;
        uint256 secondValue = 50;
        
        console2.log("--- FIRST INIT OPERATION ---");
        overflowContract.init(key, firstValue);
        
        console2.log("--- BEFORE-Trigger init ---");
        uint256 mapValueBefore = overflowContract.getMapValue(key);
        uint256 userOpCountBefore = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountBefore = overflowContract.totalOperations();
        
        console2.log("Map value before:", mapValueBefore);
        console2.log("User operation count before:", userOpCountBefore);
        console2.log("Total operations before:", totalOpCountBefore);

        console2.log("--- Trigger init ---");
        overflowContract.init(key, secondValue);
        
        console2.log("--- AFTER-Trigger init ---");
        uint256 mapValueAfter = overflowContract.getMapValue(key);
        uint256 userOpCountAfter = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountAfter = overflowContract.totalOperations();
        
        console2.log("Map value after:", mapValueAfter);
        console2.log("User operation count after:", userOpCountAfter);
        console2.log("Total operations after:", totalOpCountAfter);

        bool firstUnderflow = mapValueBefore == type(uint256).max - firstValue + 1;
        bool subsequentUnderflow = mapValueAfter == mapValueBefore - secondValue;
        bool opCountIncreased = userOpCountAfter == userOpCountBefore + 1;
        bool totalOpCountIncreased = totalOpCountAfter == totalOpCountBefore + 1;

        console2.log("First underflow occurred?", firstUnderflow ? "YES" : "NO");
        console2.log("Subsequent underflow occurred?", subsequentUnderflow ? "YES" : "NO");
        console2.log("User op count increased?", opCountIncreased ? "YES" : "NO");
        console2.log("Total op count increased?", totalOpCountIncreased ? "YES" : "NO");

        if (firstUnderflow && subsequentUnderflow) {
            console2.log("Vulnerability Exists: Subsequent underflow maintained overflow state");
        } else {
            console2.log("Vulnerability not Exist: No integer underflow cascade occurred");
        }
    }

    function testLargeUnderflow() public {
        uint256 key = 3;
        uint256 hugeValue = type(uint256).max - 100;
        
        console2.log("--- BEFORE-Trigger init ---");
        uint256 userOpCountBefore = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountBefore = overflowContract.totalOperations();
        uint256 lastOpTimeBefore = overflowContract.lastOperationTime();
        
        console2.log("User operation count before:", userOpCountBefore);
        console2.log("Total operations before:", totalOpCountBefore);
        console2.log("Last operation time before:", lastOpTimeBefore);

        console2.log("--- Trigger init ---");
        overflowContract.init(key, hugeValue);
        
        console2.log("--- AFTER-Trigger init ---");
        uint256 mapValueAfter = overflowContract.getMapValue(key);
        uint256 userOpCountAfter = overflowContract.getUserOperationCount(address(this));
        uint256 totalOpCountAfter = overflowContract.totalOperations();
        uint256 lastOpTimeAfter = overflowContract.lastOperationTime();
        uint256 blockTimestamp = block.timestamp;
        
        console2.log("Map value after:", mapValueAfter);
        console2.log("User operation count after:", userOpCountAfter);
        console2.log("Total operations after:", totalOpCountAfter);
        console2.log("Last operation time after:", lastOpTimeAfter);
        console2.log("Current block timestamp:", blockTimestamp);

        bool underflowOccurred = mapValueAfter < hugeValue;
        bool opCountIncreased = userOpCountAfter == userOpCountBefore + 1;
        bool totalOpCountIncreased = totalOpCountAfter == totalOpCountBefore + 1;
        bool timeUpdated = lastOpTimeAfter == blockTimestamp;

        console2.log("Integer underflow occurred?", underflowOccurred ? "YES" : "NO");
        console2.log("User op count increased?", opCountIncreased ? "YES" : "NO");
        console2.log("Total op count increased?", totalOpCountIncreased ? "YES" : "NO");
        console2.log("Last op time updated?", timeUpdated ? "YES" : "NO");

        if (underflowOccurred) {
            console2.log("Vulnerability Exists: Large value caused integer underflow");
        } else {
            console2.log("Vulnerability not Exist: No integer underflow occurred");
        }
    }
}