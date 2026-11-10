// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoRace.sol";

contract MockWBNB {
    function deposit() external payable {}
    function transfer(address, uint) external pure returns (bool) { return true; }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFECafe);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    function initialize(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint /* deadline */
    ) external payable {
        // Empty mock implementation
    }
}

contract CryptoRaceVulnerabilityTest is Test {
    CryptoRace cryptoRaceToken;
    
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant HARDCODED_WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    function setUp() public {
        // Deploy mocks
        MockFactory mockFactory = new MockFactory();
        MockWBNB mockWBNB = new MockWBNB();
        MockRouter mockRouter = new MockRouter();
        
        // Simulate hardcoded addresses by deploying mock code to them
        vm.etch(HARDCODED_WBNB, address(mockWBNB).code);
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);
        
        // Initialize router state (storage slots)
        bytes32 factorySlot = bytes32(uint256(0)); // First storage slot
        bytes32 wethSlot = bytes32(uint256(1)); // Second storage slot
        
        vm.store(HARDCODED_ROUTER, factorySlot, bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(HARDCODED_ROUTER, wethSlot, bytes32(uint256(uint160(HARDCODED_WBNB))));
        
        // Deploy token contract - now sees mock implementations at hardcoded addresses
        cryptoRaceToken = new CryptoRace();
        
        // Authorize test contract for admin functions
        cryptoRaceToken.authorize(address(this));
    }

    function testBuybackVulnerability() public {
        // Fund token contract (needs ETH for swap)
        vm.deal(address(cryptoRaceToken), 1 ether);
        
        console.log("--- BEFORE-Trigger buyback ---");
        uint256 initialETH = address(cryptoRaceToken).balance;
        console.log("Token contract ETH balance:", initialETH);
        console.log("Is buyback possible? (If initialETH > 0)");

        uint256 buybackAmount = 0.5 ether;
        bool success;
        
        console.log("--- TRIGGER: call triggerManualBuyback() ---");
        try cryptoRaceToken.triggerManualBuyback(buybackAmount, false) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger buyback ---");
        uint256 finalETH = address(cryptoRaceToken).balance;
        console.log("Token contract ETH balance:", finalETH);
        console.log("Did buyback execute without reverting?", success ? "Yes" : "No");

        // Final vulnerability verdict
        if (success) {
            console.log("Vulnerability Exists: Buyback executed with unsafe hardcoded router design");
        } else {
            console.log("Vulnerability not Exist: Buyback reverted unexpectedly");
        }
    }
}