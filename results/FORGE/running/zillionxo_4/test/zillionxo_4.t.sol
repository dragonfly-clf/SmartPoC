// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZAX.sol";

contract MockWETH {
    function deposit() external payable {}
}

contract MockFactory {
    address public pairAddress;

    constructor(address _pair) {
        pairAddress = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}

contract MockRouter {
    MockFactory internal _factory;
    address internal _weth;
    
    constructor(address weth, address pair) {
        _weth = weth;
        _factory = new MockFactory(pair);
    }

    function factory() external view returns (address) {
        return address(_factory);
    }

    function WETH() external view returns (address) {
        return _weth;
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external {}
}

contract ZAX_ZeroDivisionTest is Test {
    ZAX token;
    address owner = address(this);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address marketingWallet = makeAddr("marketing");
    address buybackWallet = makeAddr("buyback");
    address deadWallet = 0x000000000000000000000000000000000000dEaD;

    MockRouter router;
    address pair;
    uint256 tokenAmount;

    function setUp() public {
        vm.deal(owner, 10 ether);
        address weth = address(new MockWETH());

        // Deploy mock pair for the token
        pair = makeAddr("pair");
        router = new MockRouter(weth, pair);

        // Deploy token contract
        token = new ZAX(address(router));

        // Configure token
        token.updateMarketingWallet(marketingWallet);
        token.updatebuybackWallet(buybackWallet);
        token.setTaxes(0, 0, 0, 0); // Set all taxes to zero
        token.setSellTaxes(0, 0, 0, 0);
        
        // Calculate base token amount (in decimal units)
        uint tokenTotalSupply = token.totalSupply();
        tokenAmount = tokenTotalSupply / 100; // Use a percentage of total supply
        if (tokenAmount == 0) tokenAmount = 1e15; // Fallback if total supply is very low
        
        token.updateMaxTxLimit(tokenAmount, tokenAmount);
        token.updateMaxWalletlimit(tokenAmount * 100);
        token.updateSwapTokensAtAmount(1); // Will cause division by zero
        token.updateSwapEnabled(true);
        token.setTradingStatus(true, 0, 0, 0, 0, 0);

        // Transfer tokens to Alice
        require(token.transfer(alice, tokenAmount), "Transfer to Alice failed");
    }

    function test_ZeroDivisionInSwapAndLiquify() public {
        console.log("--- BEFORE: State Prior to Trigger ---");
        uint contractTokenBalance = token.balanceOf(address(token));
        uint aliceBalance = token.balanceOf(alice);
        uint bobBalance = token.balanceOf(bob);
        console.log("Contract token balance:", contractTokenBalance);
        console.log("Alice token balance:", aliceBalance);
        console.log("Bob token balance:", bobBalance);

        // Transfer tokens to contract to trigger swap condition
        console.log("Pre-trigger: seeding contract with 1 token");
        token.transfer(address(token), 1);
        
        console.log("--- TRIGGER: Execute Zero-Division Transfer ---");
        console.log("Attempting transfer from Alice to Bob (1 token)");
        
        bool success;
        bytes memory data;
        vm.startPrank(alice);
        (success, data) = address(token).call(abi.encodeWithSelector(token.transfer.selector, bob, 1));
        vm.stopPrank();
        
        console.log("--- AFTER: State After Trigger ---");
        console.log("Contract token balance:", token.balanceOf(address(token)));
        console.log("Alice token balance:", token.balanceOf(alice));
        console.log("Bob token balance:", token.balanceOf(bob));
        console.log(success ? "Transfer succeeded" : "Transfer reverted");
        if (!success) {
            console.logBytes(data);
        }
        
        // Vulnerability verification
        bool vulnerabilityExists = false;
        if (!success && data.length > 0) {
            // Check for division by zero panic signature
            if (bytes4(data) == 0x4e487b71) { // Panic(uint256) selector
                vulnerabilityExists = true;
            }
        }
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Division by zero occurred during transfer");
        } else {
            console.log("Vulnerability not Exist: Transaction didn't revert with division by zero");
        }
    }
}