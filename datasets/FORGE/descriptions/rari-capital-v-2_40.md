## QSP-41 Controller unable to pause specific stablecoins

#### Severity: Low Risk

 Status: Acknowledged

###### File(s) affected: rari-stable-pool-contracts/.../DydxPoolController.sol, rari-stable-pool-contracts/.../AavePoolController.sol, rari-stable-pool```
contracts/.../CompoundPoolController.sol

```

###### Description: Stablecoins, like other financial assets on-chain, are likely victims of recurrent attacks or attempted attacks. In case of specific disruption of any stablecoin, the controllers of the
 pools have no functionality to selectively pause or stop the use of particular stablecoin.

 Recommendation: Add functionality to pause specific stablecoins or update the addresses of any stablecoin contract.

# Automated Analyses

### Slither

#### Slither has detected a total of 226 issues. We have marked the majority as false positives. Some of the issues were incorporated in the finding and best practices sections.

 Additionally slither has found that solidity naming conventions have not been respected:

```
Constant RariFundProxy._weth (RariFundProxy.sol#115) is not in UPPER_CASE_WITH_UNDERSCORES
Function LibMathRichErrors.DivisionByZeroError() (@0x/contracts-exchange-libs/contracts/src/LibMathRichErrors.sol#15-21) is not in mixedCase
Function LibMathRichErrors.RoundingError(uint256,uint256,uint256) (@0x/contracts-exchange-libs/contracts/src/LibMathRichErrors.sol#23-38) is not in mixedCase
Function LibSafeMathRichErrors.Uint256BinOpError(LibSafeMathRichErrors.BinOpErrorCodes,uint256,uint256) (@0x/contracts-utils/contracts/src/LibSafeMathRichErrors.sol#28-43) is not in mixedCase
Function LibSafeMathRichErrors.Uint256DowncastError(LibSafeMathRichErrors.DowncastErrorCodes,uint256) (@0x/contracts-utils/contracts/src/LibSafeMathRichErrors.sol#45-58) is not in mixedCase
Constant ZeroExExchangeController._exchange (lib/exchanges/ZeroExExchangeController.sol#44) is not in UPPER_CASE_WITH_UNDERSCORES
Constant AavePoolController._lendingPool (lib/pools/AavePoolController.sol#41) is not in UPPER_CASE_WITH_UNDERSCORES
Variable RariFundManager._cachePoolBalances (RariFundManager.sol#388) is not in mixedCase
Variable RariFundManager._cacheDydxBalances (RariFundManager.sol#393) is not in mixedCase
Variable RariFundManager._poolBalanceCache (RariFundManager.sol#398) is not in mixedCase
Function RariFundController._getPoolBalance(uint8,string) (RariFundController.sol#265-272) is not in mixedCase
Variable RariFundController._poolsWithFunds (RariFundController.sol#328) is not in mixedCase
Variable RariFundController._aaveReferralCode (RariFundController.sol#342) is not in mixedCase
Function LibRichErrors.StandardError(string) (@0x/contracts-utils/contracts/src/LibRichErrors.sol#34-45) is not in mixedCase
Constant DydxPoolController._soloMargin (lib/pools/DydxPoolController.sol#43) is not in UPPER_CASE_WITH_UNDERSCORES
Parameter Migrations.upgrade(address).new_address (Migrations.sol#28) is not in mixedCase
Variable Migrations.last_completed_migration (Migrations.sol#14) is not in mixedCase
Function LibBytesRichErrors.InvalidByteOperationError(LibBytesRichErrors.InvalidByteOperationErrorCodes,uint256,uint256) (@0x/contracts-utils/contracts/src/LibBytesRichErrors.sol#40-55) is not in mixedCase

```

## Adherence to Specification