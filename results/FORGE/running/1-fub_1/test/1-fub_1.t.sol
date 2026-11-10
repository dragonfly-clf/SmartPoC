// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";
import "../src/BABYTOKEN.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint256) external {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xbeef);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract BABYTOKENBlacklistTest is Test {
    BABYTOKEN token;
    BABYTOKENDividendTracker dividendTrackerImpl;
    
    address deployer = address(0x1);
    address victim = address(0x2);
    address receiver = address(0x3);
    
    function setUp() public {
        vm.startPrank(deployer);
        
        // Deploy mock Uniswap components
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Deploy dividend tracker implementation
        dividendTrackerImpl = new BABYTOKENDividendTracker();
        
        // Token constructor parameters
        address[4] memory addrs = [
            address(0x111), // rewardToken
            address(mockRouter), // router
            address(0x112), // marketing wallet
            address(dividendTrackerImpl) // dividendTracker implementation
        ];
        
        uint256[4] memory buyFees = [uint256(0), 0, 0, 0];
        uint256[4] memory sellFees = [uint256(0), 0, 0, 0];
        
        // Deploy token with corrected parameters
        token = new BABYTOKEN(
            "TestToken", 
            "TST", 
            1_000_000 ether, // totalSupply
            addrs,
            buyFees,
            sellFees,
            0, // tokenBalanceForReward
            address(0), // serviceFeeReceiver
            0 // serviceFee
        );
        
        // Mint tokens to victim
        token.transfer(victim, 1000 ether);
        vm.stopPrank();
    }

    function testOwnerCanBlacklistAccount() public {
        console.log("--- PRE-TRIGGER STATE ---");
        console.log("Victim balance:", token.balanceOf(victim));
        console.log("Receiver balance:", token.balanceOf(receiver));
        console.log("Attempting innocent transfer...");
        vm.prank(victim);
        token.transfer(receiver, 100 ether);
        console.log("Innocent transfer succeeded");

        console.log("--- TRIGGER ACTION ---");
        vm.startPrank(deployer);
        // Create list of addresses to blacklist
        address[] memory accounts = new address[](1);
        accounts[0] = victim;
        console.log("Owner blacklisting victim...");
        token.multipleBotlistAddress(accounts, true);
        vm.stopPrank();

        console.log("--- POST-TRIGGER STATE ---");
        console.log("Victim balance:", token.balanceOf(victim));
        console.log("Receiver balance:", token.balanceOf(receiver));
        console.log("Attempting transfer as blacklisted victim...");

        vm.startPrank(victim);
        vm.expectRevert();
        token.transfer(receiver, 100 ether);
        vm.stopPrank();
        console.log("Transfer correctly blocked by blacklist");

        // Final vulnerability verdict
        console.log("\nVulnerability Exists: Owner permission bypass verified");
    }
}