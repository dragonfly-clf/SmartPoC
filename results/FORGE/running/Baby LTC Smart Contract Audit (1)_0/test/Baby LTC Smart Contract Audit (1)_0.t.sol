// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract BabyTokenTest is Test {
    BABYTOKEN internal token;
    address internal owner = address(this);
    address internal attacker = address(0x2);
    
    ServiceFeeReceiver internal feeReceiver;
    
    // Mock contracts
    MockERC20 internal mockRewardToken;
    MockRouter internal mockRouter;
    MockFactory internal mockFactory;

    function setUp() public {
        vm.deal(address(this), 2 ether);
        
        // Deploy service fee receiver
        feeReceiver = new ServiceFeeReceiver();
        
        // Deploy mock token for dividends
        mockRewardToken = new MockERC20("Reward Token", "REW");
        
        // Setup Uniswap mock ecosystem
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), address(new MockERC20("WETH", "WETH")));
        
        // Token constructor parameters
        address[4] memory addrs = [
            address(mockRewardToken), 
            address(mockRouter), 
            address(0x3), // Marketing wallet
            address(new MockDividendTracker()) // Dividend tracker implementation
        ];
        
        uint256[3] memory feeSettings = [uint256(1), 1, 1];
        uint256 minTokenBalance = 1 ether;
        
        // Deploy token
        token = new BABYTOKEN{value: 1 ether}(
            "TestToken",
            "TEST",
            100_000 ether, // Total supply
            addrs,
            feeSettings,
            minTokenBalance,
            address(feeReceiver), // Service fee receiver (with fallback)
            1 ether // Service fee
        );
    }

    function test_ProcessDividendTrackerAccessControl() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Caller: owner (expected to have privileges)");
        console.log("--- END BEFORE ---");
        
        console.log("--- Trigger Attacker Action ---");
        console.log("Caller: attacker (non-owner)");
        console.log("Call: token.processDividendTracker(300000)");
        
        console.log("--- AFTER-Trigger Result Check ---");
        bool success;
        vm.prank(attacker);
        try token.processDividendTracker(300000) {
            success = true;
        } catch {
            success = false;
        }
        
        console.log("Execution result:", success ? "SUCCESS" : "REVERTED");
        
        if (success) {
            console.log("Vulnerability Exists: Non-owner can access processDividendTracker");
        } else {
            console.log("Vulnerability not Exist: Access control prevents non-owner access");
        }
    }
}

contract ServiceFeeReceiver {
    receive() external payable {}
}

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function balanceOf(address) external pure returns (uint256) {
        return 1 ether;
    }
}

contract MockFactory {
    address public pair = address(0x6);
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockDividendTracker {
    function initialize(address, uint256) external pure {}
    
    function process(uint256) public pure returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
    
    function excludeFromDividends(address) external pure {}
}