// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Play2Burn.sol";

contract MockToken {
    bool public shouldFail;
    mapping(address => uint256) public balanceOf;
    
    constructor(bool _shouldFail) {
        shouldFail = _shouldFail;
    }
    
    function mint(address _to, uint256 _amount) external {
        balanceOf[_to] = _amount;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        if (shouldFail) {
            return false;
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external view returns (address) {
        return address(0xDEAD); // Dummy pair address
    }
}

contract AuditTestPlay2Burn is Test {
    Play2Burn public play2burn;
    MockToken public failingToken;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.startPrank(owner);
        
        // Setup mock Uniswap environment
        address mockFactory = address(new MockFactory());
        address mockWETH = address(0xCAFE);
        
        // Mock PancakeSwap router
        MockRouter routerContract = new MockRouter(mockFactory, mockWETH);
        bytes memory routerCode = address(routerContract).code;
        vm.etch(PANCAKE_ROUTER, routerCode);
        
        // Deploy Play2Burn contract
        play2burn = new Play2Burn();
        
        // Deploy and setup failing ERC20 token
        failingToken = new MockToken(true);
        failingToken.mint(address(play2burn), 1000 ether);
        
        vm.stopPrank();
    }

    function test_ClaimStuckTokensIgnoredReturnValue() public {
        console.log("--- BEFORE-Trigger TokensBalances ---");
        // Record initial token balances
        uint256 initialContractBalance = failingToken.balanceOf(address(play2burn));
        uint256 initialOwnerBalance = failingToken.balanceOf(owner);
        console.log("Initial Contract Token Balance:", initialContractBalance);
        console.log("Initial Owner Token Balance:", initialOwnerBalance);

        console.log("--- Trigger: claimStuckTokens ---");
        // Execute the function call
        vm.prank(owner);
        play2burn.claimStuckTokens(address(failingToken));

        console.log("--- AFTER-Trigger TokensBalances ---");
        // Record final token balances
        uint256 finalContractBalance = failingToken.balanceOf(address(play2burn));
        uint256 finalOwnerBalance = failingToken.balanceOf(owner);
        console.log("Final Contract Token Balance:", finalContractBalance);
        console.log("Final Owner Token Balance:", finalOwnerBalance);

        // Verify token balances unchanged in state
        assertEq(finalContractBalance, initialContractBalance, "Tokens should remain stuck in contract");
        assertEq(finalOwnerBalance, initialOwnerBalance, "Owner should not receive tokens");
        
        // Determine vulnerability based on balance comparison
        if (finalContractBalance == initialContractBalance && 
            finalOwnerBalance == initialOwnerBalance) {
            console.log("Vulnerability Exists: Contract ignores failed token transfers without reverting");
        } else {
            console.log("Vulnerability not Exist: Token balances changed unexpectedly");
        }
    }
}