// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract FalseReturnToken is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    function transfer(address, uint256) public pure override returns (bool) {
        return false;
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        return false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function mint(address account, uint256 amount) public {
        _balances[account] += amount;
    }

    function approve(address, uint256) public pure override returns (bool) {
        return true;
    }

    function allowance(address, address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    function totalSupply() public pure override returns (uint256) {
        return 1e24;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;

    constructor() {
        factory = address(new MockUniswapV2Factory());
    }

    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract UncheckedTransferTest is Test {
    FalseReturnToken public falseToken;
    address public marketingWallet = address(0x2);
    BABYTOKEN public babyToken;
    address public alice = address(0x1);
    address public owner = address(this);

    function setUp() public {
        falseToken = new FalseReturnToken();
        MockUniswapV2Router router = new MockUniswapV2Router();
        BABYTOKENDividendTracker impl = new BABYTOKENDividendTracker();
        
        address[4] memory addrs = [
            address(falseToken),
            address(router),
            marketingWallet,
            address(impl)
        ];
        
        uint256[3] memory feeSettings = [
            uint256(1),
            uint256(1),
            uint256(1)
        ];
        
        babyToken = new BABYTOKEN{value: 0}(
            "TestToken",
            "TEST",
            10000 * 10**18,
            addrs,
            feeSettings,
            1 * 10**18,
            address(0),
            0
        );
        
        babyToken.transfer(alice, 100 * 10**18);
        BABYTOKENDividendTracker dividendTracker = babyToken.dividendTracker();
        falseToken.mint(address(dividendTracker), 100 * 10**18);

        vm.prank(address(babyToken));
        dividendTracker.distributeCAKEDividends(100 * 10**18);
    }

    function testUncheckedTransferVulnerability() public {
        BABYTOKENDividendTracker dividendTracker = babyToken.dividendTracker();
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 withdrawableBefore = dividendTracker.withdrawableDividendOf(alice);
        uint256 balanceBefore = falseToken.balanceOf(alice);
        console.log("Alice's withdrawable dividend: %s", withdrawableBefore);
        console.log("Alice's falseToken balance: %s", balanceBefore);
        assertGt(withdrawableBefore, 0, "No withdrawable dividends");

        console.log("--- Trigger Claim Operation ---");
        vm.prank(alice);
        babyToken.claim();

        console.log("--- AFTER-Trigger State ---");
        uint256 withdrawableAfter = dividendTracker.withdrawableDividendOf(alice);
        uint256 balanceAfter = falseToken.balanceOf(alice);
        console.log("Alice's withdrawable dividend: %s", withdrawableAfter);
        console.log("Alice's falseToken balance: %s", balanceAfter);

        // Vulnerability check logic
        bool stateUnchanged = (withdrawableAfter == withdrawableBefore) && 
                              (balanceAfter == balanceBefore);
        
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Token transfer failed silently without updating dividend state");
        } else {
            console.log("Vulnerability not Exist: Token transfer succeeded or state was updated");
        }
    }
}