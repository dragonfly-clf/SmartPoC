// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetBitcoinAi.sol";

contract FailingToken {
    mapping(address => uint256) public balances;
    bool public shouldFail;

    constructor() {
        balances[msg.sender] = 1000 ether;
    }

    function setFail(bool _shouldFail) external {
        shouldFail = _shouldFail;
    }

    function transfer(address to, uint256) external returns (bool) {
        if (shouldFail) return false;
        balances[msg.sender] -= 1 ether;
        balances[to] += 1 ether;
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract BetBitcoinAiTest is Test {
    BetBitcoinAi public bbToken;
    FailingToken public failingToken;
    address public owner;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public constant RESCUE_AMOUNT = 100 ether;
    
    function setUp() public {
        // Setup router mocks
        address dummyFactory = address(0xABCD);
        address dummyWETH = address(0x1234);
        address dummyPair = address(0x5678);
        
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(dummyFactory));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(dummyWETH));
        vm.mockCall(dummyFactory, abi.encodeWithSignature("createPair(address,address)"), abi.encode(dummyPair));

        bbToken = new BetBitcoinAi();
        owner = bbToken.owner();
        failingToken = new FailingToken();
        
        // Enable successful transfers for setup
        failingToken.setFail(false);
        
        // Transfer tokens to bbToken contract for rescue test
        failingToken.transfer(address(bbToken), RESCUE_AMOUNT);
        
        // Enable failures for actual test
        failingToken.setFail(true);
    }

    function test_RescueERC20FailsSilently() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        // Pre-trigger state capture
        uint256 initialOwnerBalance = failingToken.balanceOf(owner);
        uint256 initialBBTokenBalance = failingToken.balanceOf(address(bbToken));
        console.log("Owner Balance BEFORE: %s", initialOwnerBalance);
        console.log("Contract Balance BEFORE: %s", initialBBTokenBalance);

        console.log("--- Trigger Rescue ---");
        // Attempt rescue via low-level call to capture success status
        vm.prank(owner);
        (bool success,) = address(bbToken).call(
            abi.encodeWithSelector(BetBitcoinAi.rescueERC20.selector, address(failingToken), RESCUE_AMOUNT)
        );
        console.log("Rescue call success status: %s", success);

        console.log("--- AFTER-Trigger Rescue ---");
        // Post-trigger state capture
        uint256 finalOwnerBalance = failingToken.balanceOf(owner);
        uint256 finalBBTokenBalance = failingToken.balanceOf(address(bbToken));
        console.log("Owner Balance AFTER: %s", finalOwnerBalance);
        console.log("Contract Balance AFTER: %s", finalBBTokenBalance);
        console.log("Balances unchanged? %s", (initialOwnerBalance == finalOwnerBalance && initialBBTokenBalance == finalBBTokenBalance) ? "YES" : "NO");

        // Vulnerability verification criteria
        bool vulnerabilityExists = success && 
                                  (initialOwnerBalance == finalOwnerBalance) && 
                                  (initialBBTokenBalance == finalBBTokenBalance);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: rescueERC20 completed without reverting but token balances unchanged, indicating silent failure");
        } else {
            console.log("Vulnerability not Exist: rescueERC20 either reverted or token balances changed, preventing silent failure");
        }
    }
}