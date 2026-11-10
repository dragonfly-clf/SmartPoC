// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MEGADOGE.sol";

contract FailingToken is IERC20 {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address, uint256) external pure override returns (bool) {
        // Always fail transfers
        return false;
    }

    function transferFrom(address, address, uint256) external pure override returns (bool) {
        return false;
    }

    function approve(address, uint256) external pure override returns (bool) {
        return false;
    }

    function allowance(address, address) external pure override returns (uint256) {
        return 0;
    }

    // Mint tokens to an address
    function mint(address to, uint256 amount) external {
        _totalSupply += amount;
        _balances[to] += amount;
    }
}

contract MEGADOGE_UncheckedTransferTest is Test {
    MEGADOGE megadoge;
    FailingToken failingToken;
    address owner = makeAddr("owner");
    address payable constant PANCAKE_ROUTER = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    
    function setUp() public {
        // Create dummy Uniswap pair
        address dummyPair = makeAddr("dummyPair");
        
        // Mock PancakeSwap router and factory
        address mockFactory = address(new MockFactory(dummyPair));
        address mockRouter = address(new MockUniswapV2Router(mockFactory, WETH));
        vm.etch(PANCAKE_ROUTER, mockRouter.code);  // Override real router with mock

        // Deploy MEGADOGE contract
        vm.startPrank(owner);
        megadoge = new MEGADOGE();
        vm.stopPrank();

        // Deploy and fund failing token
        failingToken = new FailingToken();
        failingToken.mint(address(megadoge), 1000 ether);
    }

    function test_claimStuckTokens_UncheckedTransfer() public {
        // Record pre-trigger state
        uint256 preContractBalance = failingToken.balanceOf(address(megadoge));
        uint256 preOwnerBalance = failingToken.balanceOf(owner);
        
        console.log("--- BEFORE-Trigger ClaimStuckTokens ---");
        console.log("MEGADOGE contract balance: %s", preContractBalance);
        console.log("Owner balance: %s", preOwnerBalance);
        
        console.log("--- Trigger ClaimStuckTokens ---");
        // Owner attempts to claim tokens (transfer will fail silently)
        vm.prank(owner);
        megadoge.claimStuckTokens(address(failingToken));
        
        // Record post-trigger state
        uint256 postContractBalance = failingToken.balanceOf(address(megadoge));
        uint256 postOwnerBalance = failingToken.balanceOf(owner);
        
        console.log("--- AFTER-Trigger ClaimStuckTokens ---");
        console.log("MEGADOGE contract balance: %s", postContractBalance);
        console.log("Owner balance: %s", postOwnerBalance);
        
        // Calculate differences
        uint256 contractDiff = preContractBalance - postContractBalance;
        uint256 ownerDiff = postOwnerBalance - preOwnerBalance;
        bool contractBalUnchanged = contractDiff == 0;
        bool ownerBalUnchanged = ownerDiff == 0;
        
        // Print comparison results
        console.log("=== Differential Verification ===");
        console.log("Contract balance change: -%s", contractDiff);
        console.log("Owner balance change: +%s", ownerDiff);
        console.log("Contract balance unchanged: %s", contractBalUnchanged ? "YES":"NO");
        console.log("Owner balance unchanged: %s", ownerBalUnchanged ? "YES":"NO");
        
        // Vulnerability verdict: Unchanged balances indicate failure without revert
        if (contractBalUnchanged && ownerBalUnchanged) {
            console.log("Vulnerability Exists: Token transfer failed without revert leaving balances unchanged");
        } else {
            console.log("Vulnerability not Exist: Token transfer succeeded or reverted as expected");
        }
    
        // Original assertions remain
        assertEq(postContractBalance, 1000 ether, "MEGADOGE contract should retain 1000 ether");
        assertEq(postOwnerBalance, 0, "Owner should have 0 balance after failed transfer");
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract MockFactory {
    address immutable pairAddress;
    
    constructor(address _pairAddress) {
        pairAddress = _pairAddress;
    }
    
    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}