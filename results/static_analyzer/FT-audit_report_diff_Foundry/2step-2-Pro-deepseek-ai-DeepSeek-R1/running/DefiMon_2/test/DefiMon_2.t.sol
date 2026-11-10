// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DefiMon.sol";

// Minimal Mock for WETH
contract MockWETH {
    function deposit() external payable {}
    function transfer(address to, uint value) external returns (bool) {
        return true;
    }
    function approve(address, uint) external returns (bool) {
        return true;
    }
    function balanceOf(address) external view returns (uint) {
        return 0;
    }
}

// Minimal Mock for UniswapV2Pair
contract MockUniswapV2Pair {
    function token0() external pure returns (address) { 
        return address(0); 
    }
    function token1() external pure returns (address) { 
        return address(0); 
    }
    function getReserves() external pure returns (uint112, uint112, uint32) { 
        return (0, 0, 0); 
    }
}

// Minimal Mock for UniswapV2Factory
contract MockUniswapV2Factory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

// Minimal Mock for UniswapV2Router
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

contract MaliciousMinter is Test {
    DefiMon token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address constant PANCAKE_ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 constant initialTotalSupply = 200_000_000 * (10 ** 18);

    function setUp() public {
        // Deploy mock environment
        MockWETH mockWETH = new MockWETH();
        MockUniswapV2Pair mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), address(mockWETH));
        
        // Override hardcoded PancakeSwap address with mock
        vm.etch(PANCAKE_ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new DefiMon();
        vm.stopPrank();
    }

    function test_UnrestrictedMinting_Prevention() public {
        console.log("--- BEFORE-Trigger ---");
        // Record initial state
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Initial total supply: ", totalSupplyBefore);
        console.log("Initial attacker balance: ", attackerBalanceBefore);

        // Verify initial state matches expected
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        assertEq(totalSupplyBefore, initialTotalSupply, "Initial supply");
        assertEq(ownerBalanceBefore, initialTotalSupply, "Owner balance");
        
        console.log("--- Trigger Attack ---");
        // Attempt malicious mint
        (bool success,) = address(token).call(
            abi.encodeWithSelector(
                bytes4(keccak256("_mint(address,uint256)")),
                attacker,
                100_000_000 * 10**18
            )
        );
        
        console.log("--- AFTER-Trigger ---");
        // Record post-attack state
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Post-attack total supply: ", totalSupplyAfter);
        console.log("Post-attack attacker balance: ", attackerBalanceAfter);
        
        // Vulnerability verification
        bool supplyChanged = totalSupplyAfter != totalSupplyBefore;
        bool balanceChanged = attackerBalanceAfter != attackerBalanceBefore;
        bool vulnerabilityExists = supplyChanged || balanceChanged;
        
        if (vulnerabilityExists) {
            console.log("Verification: State change DETECTED - Vulnerability exists");
            console.log("Vulnerability Exists: Malicious minting succeeded");
        } else {
            console.log("Verification: State UNCHANGED - Vulnerability protected");
            console.log("Vulnerability not Exist: Malicious minting prevented");
        }

        // Verify attack prevented
        assertFalse(success, "Minting attempt should fail");
        assertEq(totalSupplyAfter, initialTotalSupply, "Total supply integrity");
        assertEq(attackerBalanceAfter, 0, "Attacker balance");
    }
}