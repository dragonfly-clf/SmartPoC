// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HuskyInu.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) { return true; }
    function approve(address, uint256) public pure returns (bool) { return true; }
}

contract MockUniswapV2Pair {}

contract MockUniswapV2Factory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function getPair(address, address) external view returns (address) {
        return pair;
    }

    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract HuskyInuTest is Test {
    HuskyInu public token;
    string constant NAME = "HuskyInu";
    string constant SYMBOL = "HUSKY";

    address constant BSC_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock ecosystem
        MockWETH mockWETH = new MockWETH();
        MockUniswapV2Pair mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        
        // Deploy mock router for code extraction
        MockUniswapV2Router tempMockRouter = new MockUniswapV2Router(address(mockFactory), address(mockWETH));
        
        // Mock BSC router address by setting its code
        vm.etch(BSC_ROUTER_ADDRESS, address(tempMockRouter).code);
        
        // Set mock values in router storage
        vm.store(
            BSC_ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            BSC_ROUTER_ADDRESS,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(address(mockWETH))))
        );

        // Deploy token
        token = new HuskyInu(NAME, SYMBOL);
    }

    function test_RouterInitialization() public {
        // Verify router address initialized correctly
        IUniswapV2Router02 router = token.uniswapV2Router();
        assertEq(address(router), BSC_ROUTER_ADDRESS, "Router address mismatch");
        
        // 漏洞存在性结论
        console.log("Vulnerability Exists: Fixed BSC router address hardcoded at deployment");
    }

    function test_RouterApproval() public {
        // Verify max approval for router
        uint256 allowance = token.allowance(address(token), BSC_ROUTER_ADDRESS);
        assertEq(allowance, type(uint256).max, "Max approval not set");
        
        // 漏洞存在性结论
        console.log("Vulnerability Exists: Unlimited approval granted to router at deployment");
    }
}