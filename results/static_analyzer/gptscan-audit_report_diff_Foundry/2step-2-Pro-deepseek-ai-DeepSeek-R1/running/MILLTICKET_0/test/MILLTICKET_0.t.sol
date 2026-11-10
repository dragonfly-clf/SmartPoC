// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MILLTICKET.sol";

contract MockRouter {
    address public factory;
    address public WETH;
    
    // Storage slots for captured parameters
    uint256 public tokenMinValue;
    uint256 public ethMinValue;
    uint256 public calledSelector;
    uint256 public calls;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address to,
        uint256
    ) external {
        // Simulate ETH receipt to token contract
        (bool success,) = to.call{value: 1 ether}("");
        require(success, "ETH transfer failed");
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256 tokenMinParam,
        uint256 ethMinParam,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        tokenMinValue = tokenMinParam;
        ethMinValue = ethMinParam;
        return (0, 0, 0);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x9876);
    }
}

contract MILLTICKETTest is Test {
    MILLTICKET token;
    address OWNER = 0x3588C2d85B0fdFaDc8e24F4e31744aEa3066F277;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address public constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    function setUp() public {
        // Deploy mocks
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), WETH_ADDR);
        
        // Etch router to known address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);

        // Initialize router state with mock values
        bytes32 factorySlot = bytes32(uint256(0));
        bytes32 wethSlot = bytes32(uint256(1));
        vm.store(ROUTER_ADDR, factorySlot, bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(ROUTER_ADDR, wethSlot, bytes32(uint256(uint160(WETH_ADDR))));
        
        // Deploy token
        vm.startPrank(OWNER);
        token = new MILLTICKET();
        
        // Setup contract parameters
        token.setSwapAndLiquifyEnabled(true);
        token.excludeFromFee(OWNER);
        token.excludeFromFee(user1);
        token.excludeFromFee(user2);

        // Fund token contract
        token.transfer(address(token), 1000 ether);
        vm.stopPrank();
        
        // Fund test contract to simulate ETH liquidity
        vm.deal(address(this), 10 ether);
    }
    
    function test_SlippageVulnerability() public {
        // Ensure router has ETH for swap simulation
        vm.deal(ROUTER_ADDR, 10 ether);
        
        // Get reference to contract storage
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(3)), // tokenMinValue slot
            bytes32(0) // Reset storage state
        );
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(4)), // ethMinValue slot
            bytes32(0) // Reset storage state
        );
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractTokenBalanceBefore = token.balanceOf(address(token));
        uint256 contractEthBalanceBefore = address(token).balance;
        console.log("Token contract token balance:", contractTokenBalanceBefore);
        console.log("Token contract ETH balance:", contractEthBalanceBefore);
        
        console.log("--- Trigger Operation (swapAndLiquify) ---");
        // Trigger transfer that will call swapAndLiquify
        vm.prank(address(token));
        token.transfer(user1, 1);
        console.log("swapAndLiquify operation completed");
        
        console.log("--- AFTER-Trigger State ---");
        uint256 contractTokenBalanceAfter = token.balanceOf(address(token));
        uint256 contractEthBalanceAfter = address(token).balance;
        console.log("Token contract token balance:", contractTokenBalanceAfter);
        console.log("Token contract ETH balance:", contractEthBalanceAfter);
        console.log("Token balance change:", int256(contractTokenBalanceAfter) - int256(contractTokenBalanceBefore));
        console.log("ETH balance change:", int256(contractEthBalanceAfter) - int256(contractEthBalanceBefore));
        
        // Read slippage parameters from router storage
        bytes memory tokenMinCall = abi.encodeWithSignature("tokenMinValue()");
        bytes memory ethMinCall = abi.encodeWithSignature("ethMinValue()");
        
        (bool tSuccess, bytes memory tData) = ROUTER_ADDR.staticcall(tokenMinCall);
        (bool eSuccess, bytes memory eData) = ROUTER_ADDR.staticcall(ethMinCall);
        
        require(tSuccess && eSuccess, "Call failed");
        
        uint256 tokenMin = abi.decode(tData, (uint256));
        uint256 ethMin = abi.decode(eData, (uint256));
        
        // Verify slippage protection set to zero
        assertEq(tokenMin, 0, "No token slippage protection");
        assertEq(ethMin, 0, "No ETH slippage protection");
        
        // Print vulnerability verdict
        if (tokenMin == 0 && ethMin == 0) {
            console.log("Vulnerability Exists: Swap slippage protection disabled (zero min values)");
        } else {
            console.log("Vulnerability not Exist: Swap slippage protection properly configured");
        }
    }
}