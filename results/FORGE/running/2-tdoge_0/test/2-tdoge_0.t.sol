// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";
import "../src/BABYTOKEN.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Reward", "MR") {
        _mint(msg.sender, 100000 ether);
    }
}

contract MockWETH {
    // Simulate WETH functionality
}

contract MockFactory {
    // Minimal factory implementation
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public immutable weth;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract BabyTokenTest is Test {
    BABYTOKEN token;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);

    MockToken rewardToken;
    MockWETH weth;
    MockFactory factory;
    MockRouter router;
    BABYTOKENDividendTracker dividendTrackerImpl;

    function setUp() public {
        // Deploy mock dependencies
        rewardToken = new MockToken();
        weth = new MockWETH();
        factory = new MockFactory();
        router = new MockRouter(address(factory), address(weth));
        dividendTrackerImpl = new BABYTOKENDividendTracker();

        // Create valid addresses array
        address[4] memory addrs = [
            address(rewardToken), // reward token
            address(router),      // router address
            owner,               // marketing wallet
            address(dividendTrackerImpl) // dividend tracker implementation
        ];
        
        uint256[4] memory buyFees = [uint256(2), 2, 2, 1]; 
        uint256[4] memory sellFees = [uint256(3), 3, 3, 2];
        uint256 totalSupply = 1000000 ether;

        // Deploy token
        token = new BABYTOKEN{value: 0}(
            "TestToken",
            "TEST",
            totalSupply,
            addrs,
            buyFees,
            sellFees,
            100 ether, // tokenBalanceForReward - real balance
            address(0), 
            0
        );

        // Distribute initial tokens
        token.transfer(alice, 100 ether);
        token.transfer(bob, 100 ether);
        token.transfer(charlie, 100 ether);
    }

    function testBlacklistFunctionality() public {
        address[] memory toBlacklist = new address[](2);
        toBlacklist[0] = alice;
        toBlacklist[1] = bob;
        
        // Owner blacklists addresses
        token.multipleBotlistAddress(toBlacklist, true);
        
        // Alice should not be able to transfer
        vm.prank(alice);
        vm.expectRevert("Blacklisted address");
        token.transfer(charlie, 10 ether);
        
        // Bob should not be able to transfer
        vm.prank(bob);
        vm.expectRevert("Blacklisted address");
        token.transfer(charlie, 10 ether);
        
        // Unblacklist Alice
        address[] memory toUnblacklist = new address[](1);
        toUnblacklist[0] = alice;
        token.multipleBotlistAddress(toUnblacklist, false);
        
        // Alice should be able to transfer now
        vm.prank(alice);
        token.transfer(charlie, 10 ether);
        assertEq(
            token.balanceOf(charlie),
            110 ether,
            "Transfer should succeed after unblacklisting"
        );
        
        // Bob should remain blocked
        vm.prank(bob);
        vm.expectRevert("Blacklisted address");
        token.transfer(charlie, 10 ether);
        
        console.log("Vulnerability Exists: Owner can arbitrarily blacklist/unblacklist any address");
    }

    function testNonOwnerCannotBlacklist() public {
        address[] memory toBlacklist = new address[](1);
        toBlacklist[0] = alice;
        
        // Expect revert when non-owner tries to blacklist
        vm.prank(charlie);
        vm.expectRevert("Ownable: caller is not the owner");
        token.multipleBotlistAddress(toBlacklist, true);
        
        console.log("Vulnerability not Exist: Non-owners cannot execute blacklist operations");
    }
    
    function testBatchBlacklisting() public {
        uint256 batchSize = 5;
        address[] memory batch = new address[](batchSize);
        
        // Generate mock addresses
        for (uint i = 0; i < batchSize; i++) {
            batch[i] = address(uint160(100 + i));
        }
        
        // Owner blacklists batch
        token.multipleBotlistAddress(batch, true);
        
        // Verify blacklisting
        for (uint i = 0; i < batchSize; i++) {
            vm.prank(batch[i]);
            vm.expectRevert("Blacklisted address");
            token.transfer(charlie, 1 wei);
        }
        
        console.log("Vulnerability Exists: Owner can simultaneously blacklist multiple addresses");
    }
}