// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RDOG.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address public immutable pair;
    
    constructor(address _pair) public {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockPair {
    // Empty mock contract for simulation
}

contract RDOGHoneypotTest is Test {
    RDOG token;
    address owner = address(this);
    address seller = address(0x2);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Mock contracts
    MockRouter mockRouter;
    MockFactory mockFactory;
    MockPair mockPair;

    // Fee receiver addresses
    address constant LPHolder_address = address(0x111);

    function getCode(address _addr) private view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
        return code;
    }

    function setUp() public {
        // Deploy mocks
        mockPair = new MockPair();
        mockFactory = new MockFactory(address(mockPair));
        mockRouter = new MockRouter(
            address(mockFactory), 
            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c // BSC WETH address
        );
        
        // Patch router address with mock router code
        vm.etch(ROUTER_ADDRESS, getCode(address(mockRouter)));
        
        // Deploy token contract
        token = new RDOG();
        
        // Set fee receiver addresses
        token.setLPHolderAddr(LPHolder_address);
        token.setLPPowerAddr(address(0x112));
        token.setFundAddr(address(0x113));
        token.setCommunityAddr(address(0x114));
        
        // Configure market pair
        token.setMarketPairStatus(address(mockPair), true);
        
        // Fund seller with tokens (1000 tokens with 18 decimals)
        uint256 amount = 1000 * 10**token.decimals();
        token.transfer(seller, amount);
    }

    function testHoneypot() public {
        console.log("=== START DIFFERENTIAL VALIDATION ===");
        
        // Record initial balances
        uint256 sellerInitBalance = token.balanceOf(seller);
        uint256 pairInitBalance = token.balanceOf(address(mockPair));
        uint256 holderInitBalance = token.balanceOf(LPHolder_address);

        console.log("--- PRE-TRIGGER STATE ---");
        console.log("Seller initial balance:      %s", sellerInitBalance);
        console.log("MockPair initial balance:     %s", pairInitBalance);
        console.log("LPHolder initial balance:     %s", holderInitBalance);

        // Configure exploit settings
        console.log("--- TRIGGER ACTION --- [EXPLOIT CONFIGURATION]");
        token.setBuyFeeEnable(false);
        token.setSellFeeEnable(true);
        token.setRates(
            100,   // Total tax = 100%
            0,     // Liquidity fee
            100,   // LP holder fee (100% of tax)
            0,     // LP power fee
            0,     // Fund fee
            0,     // Community fee
            0      // Burn fee
        );
        console.log("Configured 100% sell fee to LPHolder");

        console.log("--- TRIGGER ACTION --- [SELL TRANSFER]");
        uint256 sellAmount = token.balanceOf(seller);
        vm.prank(seller);
        token.transfer(address(mockPair), sellAmount);

        // Record final balances
        console.log("--- POST-TRIGGER STATE ---");
        uint256 sellerFinalBalance = token.balanceOf(seller);
        uint256 pairFinalBalance = token.balanceOf(address(mockPair));
        uint256 holderFinalBalance = token.balanceOf(LPHolder_address);
        uint256 holderBalanceIncrease = holderFinalBalance - holderInitBalance;

        console.log("Seller final balance:        %s", sellerFinalBalance);
        console.log("MockPair final balance:       %s", pairFinalBalance);
        console.log("LPHolder final balance:       %s", holderFinalBalance);
        console.log("LPHolder balance increase:    %s", holderBalanceIncrease);
        console.log("Expected fee allocation:      %s", sellAmount);

        // Validate state changes
        console.log("--- DIFFERENTIAL VALIDATION RESULTS ---");
        bool sellerEmptied = (sellerFinalBalance == 0);
        bool pairReceivedZero = (pairFinalBalance == pairInitBalance);
        bool feeCorrectlyAllocated = (holderBalanceIncrease == sellAmount);
        bool transferDisappeared = (pairReceivedZero && !feeCorrectlyAllocated);
        
        console.log("Seller fully drained:        %s", sellerEmptied ? "YES" : "NO");
        console.log("MockPair received 0 tokens:  %s", pairReceivedZero ? "YES" : "NO");
        console.log("Fee allocated to LPHolder:   %s", feeCorrectlyAllocated ? "CORRECT" : "INCORRECT");
        console.log("Tokens failed to transfer:   %s", transferDisappeared ? "WARNING" : "OK");

        // Final vulnerability verdict
        if (sellerEmptied && pairReceivedZero && feeCorrectlyAllocated) {
            console.log("Vulnerability Exists: Fee mechanism successfully diverted 100% of transfer to LPHolder");
        } else if (sellerEmptied && pairReceivedZero && !feeCorrectlyAllocated) {
            console.log("Vulnerability Exists: Tokens disappeared during transfer (burned/lost)");
        } else {
            console.log("Vulnerability not Exist: Token transfer did not execute as expected");
        }
    }
}