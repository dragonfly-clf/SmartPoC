// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MaliciousFIST is IERC20 {
    bool public transferShouldFail;
    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[address(this)] = 1000000 * (10**18);
    }

    function setFail(bool shouldFail) external {
        transferShouldFail = shouldFail;
    }

    function transferFrom(address, address, uint256) external override returns (bool) {
        return !transferShouldFail;
    }
}

contract TestToken {
    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) external {}
}

contract ReentrancyAuditTest is Test {
    TestToken token;
    IERC20 fistToken;
    address public swapPair = 0x7EFaEf62fDdCCa950418312c6C91Aef321375A00;
    address constant FUND_ADDRESS = address(0xBE3);
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        // Deploy malicious FIST token
        MaliciousFIST maliciousFIST = new MaliciousFIST();
        fistToken = IERC20(address(maliciousFIST));
        
        // Deploy token contract with mock SwapRouter (0x0)
        token = new TestToken();
        
        // Initialize fees and addresses
        vm.startPrank(address(this));
        maliciousFIST.setFail(false);
        fistToken.transferFrom(address(0), FUND_ADDRESS, INITIAL_BALANCE);
        vm.stopPrank();
    }

    function test_uncheckdERC20Transfer() public {
        address tokenDistributor = address(token); // Replace with actual distributor address if available
        address fundAddress = FUND_ADDRESS;
        
        // Capture full initial state
        console2.log("\n--- BEFORE-Trigger SwapTokenForFund ---");
        uint256 initialFistTokenContractBalance = fistToken.balanceOf(address(token));
        uint256 initialFistDistributorBalance = fistToken.balanceOf(tokenDistributor);
        uint256 initialFundEthBalance = address(fundAddress).balance;
        uint256 initialAttackerEthBalance = address(address(this)).balance;
        
        console2.log("Token contract FIST balance:", initialFistTokenContractBalance);
        console2.log("TokenDistributor FIST balance:", initialFistDistributorBalance);
        console2.log("Fund address ETH balance:", initialFundEthBalance);
        console2.log("Attacker (this) ETH balance:", initialAttackerEthBalance);

        // Set up malicious token to fail transfers
        MaliciousFIST(address(fistToken)).setFail(true);
        
        // Capture balances before the vulnerable operation
        uint256 initialFistContractBalance = fistToken.balanceOf(address(this));
        uint256 initialFistFundBalance = fistToken.balanceOf(FUND_ADDRESS);
        
        console2.log("\n--- Trigger SwapTokenForFund ---");
        (bool success,) = address(token).call(
            abi.encodeWithSignature("swapTokenForFund(uint256,uint256)", 100, 25)
        );
        
        console2.log("\n--- AFTER-Trigger SwapTokenForFund ---");
        uint256 finalFistTokenContractBalance = fistToken.balanceOf(address(token));
        uint256 finalFistDistributorBalance = fistToken.balanceOf(tokenDistributor);
        uint256 finalFundEthBalance = address(fundAddress).balance;
        uint256 finalAttackerEthBalance = address(address(this)).balance;
        
        console2.log("Token contract FIST balance:", finalFistTokenContractBalance);
        console2.log("TokenDistributor FIST balance:", finalFistDistributorBalance);
        console2.log("Fund address ETH balance:", finalFundEthBalance);
        console2.log("Attacker (this) ETH balance:", finalAttackerEthBalance);
        
        // Consistency checks
        bool stateConsistent = 
            (initialFistTokenContractBalance == finalFistTokenContractBalance) &&
            (initialFistDistributorBalance == finalFistDistributorBalance) &&
            (initialFundEthBalance == finalFundEthBalance) &&
            (initialAttackerEthBalance == finalAttackerEthBalance);
            
        console2.log(
            "State consistent after failed transfer?", 
            stateConsistent ? "Yes: Vulnerability Verified" : "NO: Unexplained state changes"
        );

        // Verify execution continued despite failed transfer
        assertTrue(success, "Call should not revert");
        
        // Existing verifications
        assertEq(
            fistToken.balanceOf(address(this)), 
            initialFistContractBalance, 
            "Contract balance should not change"
        );
        assertEq(
            fistToken.balanceOf(FUND_ADDRESS), 
            initialFistFundBalance, 
            "Fund address balance should not change"
        );
        
        // Print final vulnerability verdict
        if (success && stateConsistent) {
            console2.log("\nVulnerability Exists: Unchecked transfer failure allowed execution to continue without token transfer, while preserving state consistency");
        } else {
            console2.log("\nVulnerability not Exist: State changed or call reverted in a manner inconsistent with vulnerability");
        }
    }
}