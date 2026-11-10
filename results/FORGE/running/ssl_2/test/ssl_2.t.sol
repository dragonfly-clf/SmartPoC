// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBASOCCERLEAGUE.sol";

contract MockRouter {
    address public WETH;
    address public factory;
    
    constructor(address _weth, address _factory) {
        WETH = _weth;
        factory = _factory;
    }
    
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external {
        // Do nothing
    }
}

contract MockFactory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract SHIBASOCCERLEAGUE_ZeroDivisionTest is Test {
    SHIBASOCCERLEAGUE token;
    MockRouter mockRouter;
    MockFactory mockFactory;
    
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY_ADDR = address(0xC0FFEE);
    address constant MOCK_PAIR_ADDR = address(0xAAAA);
    address constant MOCK_WETH_ADDR = address(0xDECAF);

    address owner;
    address user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        
        // Create and setup mocks
        mockRouter = new MockRouter(MOCK_WETH_ADDR, MOCK_FACTORY_ADDR);
        mockFactory = new MockFactory(MOCK_PAIR_ADDR);
        
        // Setup router address with mock
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(MOCK_WETH_ADDR)))
        );
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(MOCK_FACTORY_ADDR)))
        );
        
        // Setup factory address with mock
        vm.etch(MOCK_FACTORY_ADDR, address(mockFactory).code);
        
        // Deploy token contract
        token = new SHIBASOCCERLEAGUE();
        
        // Enable trading and set zero fees
        token.tradingEnable();
        token.setSwapBackSettings(true, 1);
        token.setFees_base1000(0, 0, 0);
        
        // Transfer tokens to contract to meet swap threshold
        token.transfer(address(token), 1);
    }

    function testSwapBackRevertsOnZeroDivision() public {
        // Ensure token contract has sufficient balance
        uint256 contractBalance = token.balanceOf(address(token));
        assertGe(contractBalance, 1, "Swap threshold not met");
        
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("State: Normal (swapback enabled with zero fees)");
        console.log("Contract token balance: %d", contractBalance);

        console.log("--- Trigger Transfer ---");
        console.log("Action: token.transfer(user, 1)");
        
        string memory finalVerdict;
        try token.transfer(user, 1) {
            console.log("--- AFTER-Trigger Transfer ---");
            console.log("State: Transfer unexpectedly succeeded");
            finalVerdict = "Vulnerability not Exist: Transfer succeeded without revert";
        } catch Error(string memory reason) {
            console.log("--- AFTER-Trigger Transfer ---");
            console.log("State: Reverted with reason: %s", reason);
            if (keccak256(abi.encodePacked(reason)) == keccak256(abi.encodePacked("division by zero"))) {
                finalVerdict = "Vulnerability Exists: Reverted with division by zero";
            } else {
                finalVerdict = "Vulnerability not Exist: Reverted with unexpected reason";
            }
        } catch Panic(uint errorCode) {
            console.log("--- AFTER-Trigger Transfer ---");
            console.log("State: Reverted with Panic code: 0x%x", errorCode);
            if (errorCode == 0x12) {
                finalVerdict = "Vulnerability Exists: Reverted with division by zero panic";
            } else {
                finalVerdict = "Vulnerability not Exist: Reverted with unexpected panic";
            }
        } catch {
            console.log("--- AFTER-Trigger Transfer ---");
            console.log("State: Reverted without message");
            finalVerdict = "Vulnerability not Exist: Reverted without message";
        }
        
        console.log(finalVerdict);
    }
}