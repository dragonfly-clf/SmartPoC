// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPONGS.sol";

contract MockWETH {
    receive() external payable {}
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

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    address private constant _owner = address(0xDEAD);
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
    
    receive() external payable {}
}

contract MockERC20 {
    function approve(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract SPONGSArbitrarySendTest is Test {
    SPONGS token;
    address owner = makeAddr("owner");
    address maliciousWallet = makeAddr("malicious");
    address user = makeAddr("user");
    
    // Constants matching SPONGS constructor
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        // Create mock contracts
        MockWETH weth = new MockWETH();
        MockERC20 mockPair = new MockERC20();
        MockFactory factory = new MockFactory(address(mockPair));
        
        // Deploy mock router to precompile address
        MockRouter mockRouter = new MockRouter(address(factory), address(weth));
        
        // Etch router implementation at target address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        
        // Deploy main contract
        vm.startPrank(owner);
        token = new SPONGS();
        
        // Configure malicious state
        token.updateOperationsWallet(maliciousWallet);
        vm.stopPrank();
    }

    function test_arbitrary_eth_send() public {
        // Fund contract with ETH
        uint256 fundAmount = 1 ether;
        vm.deal(address(token), fundAmount);
        assertEq(address(token).balance, fundAmount);
        
        // Record initial balances for differential verification
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(token).balance;
        uint256 maliciousBalanceBefore = maliciousWallet.balance;
        console.log("Token contract ETH:", contractBalanceBefore);
        console.log("Operations wallet ETH:", maliciousBalanceBefore);

        // Verify only owner can access
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.recoverContractBNB(100);

        console.log("--- Trigger: recoverContractBNB(100) ---");
        // Perform critical operation - drain ETH from contract
        vm.prank(owner);
        token.recoverContractBNB(100); // 100% recovery rate

        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 maliciousBalanceAfter = maliciousWallet.balance;
        console.log("Token contract ETH:", contractBalanceAfter);
        console.log("Operations wallet ETH:", maliciousBalanceAfter);

        // Differential validation
        uint256 contractDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 maliciousGain = maliciousBalanceAfter - maliciousBalanceBefore;
        console.log("Token contract ETH change:", contractDiff);
        console.log("Operations wallet ETH change:", maliciousGain);
        require(contractDiff == fundAmount, "Contract ETH not drained");
        require(maliciousGain == fundAmount, "Wallet did not gain ETH");
        require(contractDiff == maliciousGain, "ETH flow mismatch");
        console.log("Differential verified: All ETH moved as expected");

        // Vulnerability verdict logic
        bool vulnerabilityExists = true;
        console.log("Vulnerability Exists: Owner successfully drained contract ETH to arbitrary wallet");
    }
}