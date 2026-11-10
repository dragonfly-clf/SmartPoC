// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BitGameVerse.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x333);
    }
}

contract MockRouter {
    address public immutable factoryAddress;
    
    constructor() {
        factoryAddress = address(new MockFactory());
    }
    
    function factory() external view returns (address) {
        return factoryAddress;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract BitGameVerseTest is Test {
    BitGameVerse token;
    MockRouter mockRouter;
    
    function setUp() public {
        mockRouter = new MockRouter();
        token = new BitGameVerse(address(mockRouter));
    }

    function testDeadlineUninitialized() public {
        bytes32 deadlineSlot = bytes32(uint256(10));
        
        console.log("--- BEFORE-Trigger ---");
        uint256 deadlinePre = uint256(vm.load(address(token), deadlineSlot));
        console.log("Deadline storage slot 10 value (pre): %d", deadlinePre);
        
        console.log("--- Trigger: (None - Static State Check) ---");
        
        console.log("--- AFTER-Trigger ---");
        uint256 deadlinePost = uint256(vm.load(address(token), deadlineSlot));
        console.log("Deadline storage slot 10 value (post): %d", deadlinePost);
        
        if (deadlinePre == 0 && deadlinePost == 0) {
            console.log("Vulnerability Exists: Deadline uninitialized (0)");
        } else {
            console.log("Vulnerability not Exist: Deadline initialized or changed");
        }
    }
}