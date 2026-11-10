// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/NUTGAIN.sol";

contract BadToken {
    mapping(address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
    
    // Always return false on transfer attempts
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract NUTGAINTest is Test {
    NUTGAIN nutgain;
    BadToken badToken;
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    uint256 constant TOKEN_AMOUNT = 1000 ether;

    function setUp() public {
        // Setup mock Uniswap infrastructure
        address mockWETH = address(0x1234);
        address mockPair = address(0x5678);
        address mockRouter = address(new MockRouter(address(mockPair), mockWETH));
        
        // Deploy NUTGAIN with mock router
        vm.startPrank(owner);
        nutgain = new NUTGAIN(mockRouter);
        vm.stopPrank();
        
        // Deploy malicious token that returns false on transfer
        badToken = new BadToken();
    }

    function testUncheckedTransferFailure() public {
        // Mint tokens to NUTGAIN contract
        badToken.mint(address(nutgain), TOKEN_AMOUNT);
        
        // Pre-attack state verification
        console.log("--- BEFORE-Trigger rescueAnyBEP20Tokens ---");
        uint256 preNUTGAINBalance = badToken.balanceOf(address(nutgain));
        uint256 preRecipientBalance = badToken.balanceOf(recipient);
        console.log("Pre-rescue NUTGAIN balance:", preNUTGAINBalance);
        console.log("Pre-rescue Recipient balance:", preRecipientBalance);

        // Trigger vulnerability
        console.log("--- Trigger: rescueAnyBEP20Tokens call ---");
        vm.prank(owner);
        nutgain.rescueAnyBEP20Tokens(address(badToken), recipient, TOKEN_AMOUNT);

        // Post-attack state verification
        console.log("--- AFTER-Trigger rescueAnyBEP20Tokens ---");
        uint256 postNUTGAINBalance = badToken.balanceOf(address(nutgain));
        uint256 postRecipientBalance = badToken.balanceOf(recipient);
        console.log("Post-rescue NUTGAIN balance:", postNUTGAINBalance);
        console.log("Post-rescue Recipient balance:", postRecipientBalance);

        // Differential check analysis
        bool balancesUnchanged = (preNUTGAINBalance == postNUTGAINBalance) && 
                                 (preRecipientBalance == postRecipientBalance);
        
        // Final vulnerability verdict
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Token transfer failed silently without reverting transaction");
            assertEq(
                badToken.balanceOf(address(nutgain)),
                preNUTGAINBalance,
                "NUTGAIN contract balance changed unexpectedly"
            );
            assertEq(
                badToken.balanceOf(recipient),
                preRecipientBalance,
                "Recipient balance changed unexpectedly"
            );
        } else {
            console.log("Vulnerability not Exist: Token transfer affected balances or reverted");
        }
    }
}

// Minimal mock Uniswap Router
contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _pair, address _WETH) {
        factory = address(new MockFactory(_pair));
        WETH = _WETH;
    }
}

// Minimal mock Uniswap Factory
contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external pure returns (address) {
        return address(0); // Not used in test
    }
}