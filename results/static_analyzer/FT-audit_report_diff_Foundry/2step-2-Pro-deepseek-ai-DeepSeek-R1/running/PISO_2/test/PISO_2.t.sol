// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    MockFactory public immutable factory;
    address public immutable weth;

    constructor() {
        factory = new MockFactory();
        weth = address(0x456);
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract PISO_GenesisBlockTest is Test {
    PISO public token;
    MockRouter public mockRouter;
    address public owner;

    function setUp() public {
        owner = address(this);
        mockRouter = new MockRouter();
        token = new PISO(address(mockRouter));
    }

    function testGenesisBlockSetCorrectly() public {
        console.log("--- BEFORE-Trigger GenesisBlock ---");
        uint256 beforeGenesis = token.genesis_block();
        console.log("Genesis block (before enabling trading):", beforeGenesis);
        
        console.log("--- Trigger setTradingStatus(true) ---");
        token.setTradingStatus(true);
        
        console.log("--- AFTER-Trigger GenesisBlock ---");
        uint256 afterGenesis = token.genesis_block();
        console.log("Genesis block (after enabling trading):", afterGenesis);
        
        console.log("Block number during test:", block.number);
        
        bool vulnerable = false;
        string memory reason;
        
        if (beforeGenesis != 0) {
            vulnerable = true;
            reason = "Genesis block was non-zero before enabling trading";
        } else if (afterGenesis != block.number) {
            vulnerable = true;
            reason = "Genesis block did not update to current block number";
        } 
        
        if (vulnerable) {
            console.log("Vulnerability Exists:", reason);
        } else {
            console.log("Vulnerability not Exist: Genesis block updated correctly from 0 to current block number");
        }
    }
}