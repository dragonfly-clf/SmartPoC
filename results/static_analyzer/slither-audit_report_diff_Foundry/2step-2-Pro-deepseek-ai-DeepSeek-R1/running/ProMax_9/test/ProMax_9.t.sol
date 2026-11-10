// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ProMax.sol";

// Minimal UniswapV2Router mock
contract MockRouter {
    address public WETH = address(1);
    address public factory = address(this);
    
    function createPair(address, address) external pure returns (address) {
        return address(0x02); // Mock pair address
    }
}

// Malicious token that always returns false on transfers
contract MaliciousToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
    
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ProMaxRecoverBEP20Test is Test {
    ProMax public token;
    MaliciousToken public maliciousToken;
    MockRouter public mockRouter;
    address owner;
    address feeAddress;
    
    function setUp() public {
        owner = address(this);
        feeAddress = makeAddr("feeReceiver");
        mockRouter = new MockRouter();
        
        maliciousToken = new MaliciousToken();
        
        // Setup ProMax constructor parameters
        string memory tokenName = "TestToken";
        string memory tokenSymbol = "TT";
        uint8 decimal = 18;
        uint256 amountOfTokenWei = 1000 ether;
        uint16 setMxTxPer = 1000; // 10% of total supply
        uint16 setMxWalletPer = 1000; // 10% of total supply
        
        // Configure fee wallet
        ProMax.FeeWallet memory feeWallet = ProMax.FeeWallet({
            wallet: payable(owner),
            walletCharity: payable(address(0)),
            walletFeeInBNB: false,
            walletCharityFeeInBNB: false
        });
        
        address rewardToken = address(0x123);
        uint256 minimumTokenBalanceForDividends = 0;
        
        // Setup fee structure
        ProMax.Fee memory fee = ProMax.Fee({
            setTaxFee: 0,
            setLiqFee: 0,
            setBurnFee: 0,
            setWalletFee: 0,
            setBuybackFee: 0,
            setWalletCharityFee: 0,
            setRewardFee: 0
        });
        
        address[] memory addrs = new address[](2);
        addrs[0] = address(mockRouter); // Valid router address
        addrs[1] = feeAddress; // Fee receiver address
        
        // Fund with ETH for constructor transfer
        vm.deal(address(this), 1 ether);
        
        token = new ProMax{value: 1 ether}(
            tokenName,
            tokenSymbol,
            decimal,
            amountOfTokenWei,
            setMxTxPer,
            setMxWalletPer,
            feeWallet,
            rewardToken,
            minimumTokenBalanceForDividends,
            fee,
            addrs
        );
    }
    
    function testRecoverBEP20IgnoresFailedTransfer() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("State: The malicious token is deployed and the ProMax token is initialized.");
        console.log("Action: Attacker is about to call recoverBEP20 with malicious token that fails transfers.");

        bool noRevertOccurred;
        try token.recoverBEP20(address(maliciousToken), 100 ether) {
            noRevertOccurred = true;
        } catch {
            noRevertOccurred = false;
        }

        console.log("--- Trigger: RecoverBEP20 with malicious token ---");
        
        console.log("--- AFTER-Trigger ---");
        console.log("The function call has completed without reverting: %s", noRevertOccurred ? "true" : "false");
        
        if (noRevertOccurred) {
            console.log("Vulnerability Exists: The function did not revert when the transfer failed (returned false) - it ignored the return value.");
        } else {
            console.log("Vulnerability not Exist: The function reverted when the transfer failed, which is the expected behavior.");
        }
    }
}