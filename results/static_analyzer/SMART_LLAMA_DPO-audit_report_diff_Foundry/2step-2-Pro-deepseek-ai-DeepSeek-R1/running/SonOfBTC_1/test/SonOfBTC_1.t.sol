// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SonOfBTC.sol";

contract MockWBNB {
    function deposit() external payable {}
}

contract MockPairToken {}

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
}

contract SonOfBTCTest is Test {
    SonOfBTC token;
    address owner = makeAddr("owner");
    address authorizedUser = makeAddr("authorized");
    
    // BSC addresses
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy and etch MockWBNB at WBNB_ADDRESS
        MockWBNB mockWBNB = new MockWBNB();
        vm.etch(WBNB_ADDRESS, address(mockWBNB).code);
        
        // Deploy mock pair token
        MockPairToken mockPair = new MockPairToken();
        
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        // Deploy mock router implementation to get code
        MockRouter mockRouter = new MockRouter();
        
        // Etch router address with router code
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Set factory storage slot directly at router address
        vm.store(
            ROUTER_ADDRESS,
            bytes32(0), // factory is at storage slot 0
            bytes32(abi.encode(address(mockFactory)))
        );

        vm.startPrank(owner);
        token = new SonOfBTC();
        token.authorize(authorizedUser);
        vm.stopPrank();
    }

    function testMaxWalletPercentZero() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialMaxWallet = token._maxWalletToken();
        console.log("Initial maxWalletToken: %s", initialMaxWallet);

        console.log("--- Trigger setMaxWalletPercent(0) ---");
        vm.prank(owner);
        token.setMaxWalletPercent(0);

        console.log("--- AFTER-Trigger State ---");
        uint256 afterMaxWallet = token._maxWalletToken();
        console.log("After maxWalletToken: %s", afterMaxWallet);

        if (afterMaxWallet == 0) {
            console.log("Vulnerability Exists: Max wallet set to 0");
        } else {
            console.log("Vulnerability not Exist: Max wallet not zero");
        }
    }

    function testTxLimitExceedsSupply() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialMaxTx = token._maxTxAmount();
        uint256 supply = token.totalSupply();
        uint256 invalidAmount = supply + 1;
        console.log("Initial maxTxAmount: %s", initialMaxTx);
        
        console.log("--- Trigger setTxLimit(%s) ---", invalidAmount);
        vm.prank(authorizedUser);
        token.setTxLimit(invalidAmount);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 afterMaxTx = token._maxTxAmount();
        console.log("After maxTxAmount: %s", afterMaxTx);
        
        if (afterMaxTx == invalidAmount) {
            console.log("Vulnerability Exists: Tx limit exceeds supply");
        } else {
            console.log("Vulnerability not Exist: Tx limit within supply");
        }
    }

    function testInvalidTargetLiquidity() public {
        console.log("--- BEFORE-Trigger State ---");
        // Read storage slots using explicit intermediate variables
        bytes32 slot2 = bytes32(uint256(2));
        bytes32 slot3 = bytes32(uint256(3));
        uint256 BEFORE_targetLiquidity = uint256(vm.load(address(token), slot2));
        uint256 BEFORE_targetLiquidityDenominator = uint256(vm.load(address(token), slot3));
        console.log("Initial liquidity: %s/%s", BEFORE_targetLiquidity, BEFORE_targetLiquidityDenominator);
        
        console.log("--- Trigger setTargetLiquidity(200,100) ---");
        vm.prank(authorizedUser);
        token.setTargetLiquidity(200, 100);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 AFTER_targetLiquidity = uint256(vm.load(address(token), slot2));
        uint256 AFTER_targetLiquidityDenominator = uint256(vm.load(address(token), slot3));
        console.log("After liquidity: %s/%s", AFTER_targetLiquidity, AFTER_targetLiquidityDenominator);
        
        if (AFTER_targetLiquidity >= AFTER_targetLiquidityDenominator) {
            console.log("Vulnerability Exists: Invalid liquidity ratio");
        } else {
            console.log("Vulnerability not Exist: Valid liquidity ratio");
        }
    }
}