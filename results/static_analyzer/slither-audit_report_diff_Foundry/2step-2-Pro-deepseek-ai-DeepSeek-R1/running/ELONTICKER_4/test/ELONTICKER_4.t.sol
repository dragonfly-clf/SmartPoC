// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONTICKER.sol";

contract ELONTICKERRescueTokensTest is Test {
    ELONTICKER public elon;
    MockERC20 public mockToken;
    
    address constant MARKETING_WALLET = 0x2218b890D0694AD2cef917DBee33a53e571A509d;
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Create mock factory and token pair
        address mockFactory = address(new MockFactory());
        address dummyPair = address(0x123);
        
        // Setup Uniswap router mock
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))
        );
        
        // Mock pair creation
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(dummyPair)
        );

        // Mock rewards token to prevent reverts
        vm.mockCall(
            BUSD,
            abi.encodeWithSignature("balanceOf(address)"),
            abi.encode(0)
        );
        vm.mockCall(
            BUSD,
            abi.encodeWithSignature("transfer(address,uint256)"),
            abi.encode(true)
        );

        // Deploy main contract
        elon = new ELONTICKER();
        
        // Deploy test ERC20 token
        mockToken = new MockERC20();
        mockToken.mint(address(elon), 100 ether);
    }

    function testUncheckedRescueTransfer() public {
        // BEFORE-Trigger: Record initial balances
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = mockToken.balanceOf(address(elon));
        uint256 marketingBalanceBefore = mockToken.balanceOf(MARKETING_WALLET);
        console.log("Contract token balance BEFORE:", contractBalanceBefore);
        console.log("Marketing wallet token balance BEFORE:", marketingBalanceBefore);
        
        console.log("--- Trigger RescueTokens ---");
        // Perform rescue operation with failing token transfer
        elon.rescueTokens(address(mockToken));
        
        // AFTER-Trigger: Record post-operation balances
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = mockToken.balanceOf(address(elon));
        uint256 marketingBalanceAfter = mockToken.balanceOf(MARKETING_WALLET);
        console.log("Contract token balance AFTER:", contractBalanceAfter);
        console.log("Marketing wallet token balance AFTER:", marketingBalanceAfter);
        
        // Differential validation: Compare before/after states
        bool contractBalanceUnchanged = (contractBalanceAfter == contractBalanceBefore);
        bool marketingBalanceUnchanged = (marketingBalanceAfter == marketingBalanceBefore);
        
        console.log("Contract balance unchanged:", contractBalanceUnchanged);
        console.log("Marketing balance unchanged:", marketingBalanceUnchanged);
        
        // Final vulnerability verdict - if both balances unchanged, vulnerability exists
        if (contractBalanceUnchanged && marketingBalanceUnchanged) {
            console.log("Vulnerability Exists: Balances unchanged after rescueTokens call - transfer failure not handled");
        } else {
            console.log("Vulnerability not Exist: Balances changed, rescueTokens function handled transfer properly");
        }
    }
}

contract MockFactory {}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
    
    // Mock token always returns false to simulate failed transfer
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}