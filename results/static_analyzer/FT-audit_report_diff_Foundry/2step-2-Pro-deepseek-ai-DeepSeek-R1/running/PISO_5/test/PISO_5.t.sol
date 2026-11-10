// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x4); // Fixed pair address
    }
}

contract MockRouter {
    MockFactory internal _factory;
    address public weth;

    constructor(address _weth) {
        weth = _weth;
        _factory = new MockFactory();
    }

    function factory() external view returns (address) {
        return address(_factory);
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract TestGenesisBlockFix is Test {
    PISO token;
    address owner = address(0x1);
    address user = address(0x2);
    address weth = address(0xDEAD);
    address constant PAIR = address(0x4);
    
    MockRouter router;
    uint256 public constant START_BLOCK = 100;

    function setUp() public {
        // Set block number to known base
        vm.roll(START_BLOCK);

        // Deploy mock router and tokens
        router = new MockRouter(weth);

        vm.startPrank(owner);
        token = new PISO(address(router));
        // Disable cooldown to avoid interference
        token.updateCooldown(false, 0);
        // Set trading status
        token.setTradingStatus(true);

        // Transfer initial tokens to test user
        uint256 decimals = token.decimals();
        uint256 amount = 1000 * (10**decimals);
        token.transfer(user, amount);
        vm.stopPrank();
    }

    function testSellRestriction() public {
        // Capture initial state: genesis_block
        console.log("--- BEFORE-Trigger Genesis Block ---");
        uint256 initialGenesisBlock = token.genesis_block();
        console.log("Initial genesis_block value: %s", initialGenesisBlock);
        
        uint256 amount = 100 * (10**token.decimals());
        
        // Test sell restrictions in blocks 100 to 103 (genesis_block + 0 to +3)
        for (uint256 blockNum = START_BLOCK; blockNum <= START_BLOCK + 3; blockNum++) {
            vm.roll(blockNum);
            vm.startPrank(user);
            vm.expectRevert("Sells not allowed for first 3 blocks");
            token.transfer(PAIR, amount);
            vm.stopPrank();
        }

        // Confirm sells work starting at block 104
        vm.roll(START_BLOCK + 4);
        vm.startPrank(user);
        token.transfer(PAIR, amount);
        vm.stopPrank();

        // Capture final state: genesis_block
        console.log("--- AFTER-Trigger Genesis Block ---");
        uint256 finalGenesisBlock = token.genesis_block();
        console.log("Final genesis_block value: %s", finalGenesisBlock);

        // Compare states and determine vulnerability status
        if (initialGenesisBlock != finalGenesisBlock) {
            console.log("Vulnerability Exists: genesis_block was modified during test operations");
        } else {
            console.log("Vulnerability not Exist: genesis_block remains constant throughout operations");
        }
    }
}