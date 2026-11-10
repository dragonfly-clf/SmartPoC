// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ProMax.sol";

contract MaliciousReceiver {
    ProMax token;
    bool public attacked;

    constructor(address _token) {
        token = ProMax(payable(_token));
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            // Reenter during ETH transfer
            token.balanceOf(address(this));
        }
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor() {
        factory = address(new MockFactory());
        WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // Dummy WETH
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external {
        // Mock implementation
    }
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256, uint256, uint256) {
        // Mock implementation
        return (0, 0, 0);
    }
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        return address(0x123);
    }
}

contract ProMaxTest is Test {
    ProMax token;
    MaliciousReceiver attacker;
    MockRouter mockRouter;
    address OWNER = makeAddr("owner");
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        vm.startPrank(OWNER);
        vm.deal(OWNER, 10 ether);
        
        // Deploy mock router
        mockRouter = new MockRouter();
        
        // Setup minimal fee configuration
        ProMax.FeeWallet memory walletConfig = ProMax.FeeWallet({
            wallet: payable(address(this)),
            walletCharity: payable(address(0)),
            walletFeeInBNB: true,
            walletCharityFeeInBNB: false
        });
        
        // Safe fee parameters within contract limits
        ProMax.Fee memory feeConfig = ProMax.Fee({
            setTaxFee: 0,
            setLiqFee: 5,    // 0.5% (assuming 1000 basis points)
            setBurnFee: 0,
            setWalletFee: 5,  // 0.5%
            setBuybackFee: 0,
            setWalletCharityFee: 0,
            setRewardFee: 0
        });
        
        address[] memory addrs = new address[](2);
        addrs[0] = address(mockRouter); // router address
        addrs[1] = OWNER; // Receives ETH from constructor
        
        token = new ProMax{value: 1 ether}(
            "AtomicTest",
            "TEST",
            18,                 // decimals
            1_000_000 ether,    // total supply
            1000,               // 10% max TX
            2000,               // 20% max wallet
            walletConfig,
            address(0),         // rewardToken
            0,                  // min token balance for dividends
            feeConfig,
            addrs
        );
        
        // Configure and enable swap
        token.setSwapAndLiquifyEnabled(true);
        token.setFeeWallet(payable(address(this)));
        token.excludeFromFee(address(this));
        
        // Setup attacker
        attacker = new MaliciousReceiver(address(token));
        token.setFeeWallet(payable(address(attacker)));
        token.excludeFromFee(address(attacker));
        
        // Accumulate fees in contract
        token.transfer(address(token), 100000 ether);
        vm.stopPrank();
    }

    function testAtomicityViolation() public {
        vm.startPrank(OWNER);
        
        console2.log("--- BEFORE-Trigger Reentrancy Check ---");
        bool beforeAttacked = attacker.attacked();
        console2.log("Attacker reentrancy status (before):", beforeAttacked);
        
        console2.log("--- Trigger Transfer (dummyPair) ---");
        // Trigger swapAndLiquify by transferring to pair address
        bytes20 dummyPair = bytes20(uint160(0x123));
        token.transfer(address(dummyPair), 1);
        
        console2.log("--- AFTER-Trigger Reentrancy Check ---");
        bool afterAttacked = attacker.attacked();
        console2.log("Attacker reentrancy status (after):", afterAttacked);
        
        if (afterAttacked) {
            console2.log("Vulnerability Exists: Reentrancy attack succeeded");
        } else {
            console2.log("Vulnerability not Exist: Reentrancy attack not detected");
        }
        assertTrue(afterAttacked, "Reentrancy attack not detected");
        vm.stopPrank();
    }
}