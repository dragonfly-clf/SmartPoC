// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WEEDVERSESTRAINS.sol";

// Mock contracts for router simulation
contract MockPair {}
contract MockWETH {}
contract MockFactory {
    address public pair;
    constructor(address _pair) {
        pair = _pair;
    }
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}
contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract WEEDVERSESTRAINS_Test is Test {
    WEEDVERSESTRAINS token;
    address owner = makeAddr("owner");
    MockPair pair;
    MockFactory factory;
    MockRouter router;
    MockWETH weth;
    
    function setUp() public {
        // Set up mock Uniswap environment
        weth = new MockWETH();
        pair = new MockPair();
        factory = new MockFactory(address(pair));
        router = new MockRouter(address(factory), address(weth));
        
        // Prepare Uniswap router simulation at hardcoded address
        address hardcodedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(hardcodedRouter, address(router).code);

        // Deploy token as owner
        vm.startPrank(owner);
        token = new WEEDVERSESTRAINS();
        vm.stopPrank();
    }

    function test_owner_can_drain_all_eth() public {
        // Fund token contract with 1 ETH
        uint256 initialETH = 1 ether;
        deal(address(token), initialETH);
        
        console.log("--- BEFORE-Trigger Withdraw ---");
        // Pre-withdrawal state capture
        uint256 initialContractBalance = address(token).balance;
        uint256 initialOwnerBalance = owner.balance;
        console.log("Initial contract ETH balance:", initialContractBalance);
        console.log("Initial owner ETH balance:", initialOwnerBalance);

        console.log("--- Trigger WithdrawEth ---");
        // Owner withdraws all ETH
        vm.prank(owner);
        token.withdrawEth();

        console.log("--- AFTER-Trigger Withdraw ---");
        // Post-withdrawal state capture
        uint256 finalContractBalance = address(token).balance;
        uint256 finalOwnerBalance = owner.balance;
        console.log("Final contract ETH balance:", finalContractBalance);
        console.log("Final owner ETH balance:", finalOwnerBalance);
        
        // Calculate balance changes
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 ownerBalanceChange = finalOwnerBalance - initialOwnerBalance;
        
        // Vulnerability verification
        bool vulnerabilityExists = (contractBalanceChange == initialETH) && 
                                 (ownerBalanceChange == initialETH);
        
        // Format and print verdict
        console.log("Vulnerability verification:");
        console.log("Contract ETH drained? %s", contractBalanceChange == initialETH);
        console.log("Owner received ETH? %s", ownerBalanceChange == initialETH);
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can drain all ETH from contract");
        } else {
            console.log("Vulnerability not Exist: ETH drain unsuccessful");
        }
    }
}