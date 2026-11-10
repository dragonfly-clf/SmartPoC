pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockUniswapV2Factory());
        WETH = address(0);
    }
}

contract MaliciousToken {
    mapping(address => uint256) private _balances;
    
    function setBalance(address account, uint256 amount) external {
        _balances[account] = amount;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract SlappyCatTest is Test {
    SlappyCat token;
    MaliciousToken maliciousToken;
    address owner = makeAddr("owner");
    uint256 maliciousTokenBalance = 100 ether;
    uint256 ethBalance = 10 ether;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.chainId(1); // Ensure proper router initialization
        vm.startPrank(owner);

        // Deploy mock router to expected address
        MockUniswapV2Router router = new MockUniswapV2Router();
        vm.etch(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(router).code);

        // Deploy the actual token
        token = new SlappyCat();
        
        // Initialize malicious token and fund token contract
        maliciousToken = new MaliciousToken();
        maliciousToken.setBalance(address(token), maliciousTokenBalance);
        
        // Fund contract with ETH for native token test
        payable(address(token)).transfer(ethBalance);
        vm.stopPrank();
    }

    function test_IgnoresReturnValue_ERC20TransferFails() public {
        vm.startPrank(owner);
        
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = maliciousToken.balanceOf(address(token));
        uint256 ownerBalanceBefore = maliciousToken.balanceOf(owner);
        console.log("Contract malicious token balance: ", contractBalanceBefore);
        console.log("Owner malicious token balance: ", ownerBalanceBefore);

        // Trigger operation
        console.log("--- Trigger claimStuckTokens (malicious ERC20) ---");
        token.claimStuckTokens(address(maliciousToken));
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = maliciousToken.balanceOf(address(token));
        uint256 ownerBalanceAfter = maliciousToken.balanceOf(owner);
        console.log("Contract malicious token balance: ", contractBalanceAfter);
        console.log("Owner malicious token balance: ", ownerBalanceAfter);
        vm.stopPrank();

        // Comparison verdict
        bool contractUnchanged = contractBalanceAfter == contractBalanceBefore;
        bool ownerUnchanged = ownerBalanceAfter == ownerBalanceBefore;
        bool vulExists = contractUnchanged && ownerUnchanged;

        if (vulExists) {
            console.log("Vulnerability Exists: Malicious token transfer failed silently without changing balances");
        } else {
            console.log("Vulnerability not Exist: Contract properly handled ERC20 transfer return value");
        }
    }

    function test_NativeTransferSucceeds() public {
        vm.startPrank(owner);
        
        // Pre-check balances
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialContractBalance = address(token).balance;
        
        // Claim native tokens (should succeed)
        token.claimStuckTokens(address(0));
        
        // Post-check balances
        assertEq(address(token).balance, 0, "Contract should have zero ETH");
        assertEq(owner.balance, initialOwnerBalance + initialContractBalance, "Owner should receive ETH");
        vm.stopPrank();
    }
}