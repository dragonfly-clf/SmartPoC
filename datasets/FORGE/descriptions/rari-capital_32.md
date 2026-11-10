## QSP-33 Expired cache

#### Severity: Undetermined

 Status: Acknowledged

###### File(s) affected: RariFundManager.sol

 Description: The functions _depositTo _withdrawFrom,, and withdrawFees in RariFundManager.sol@rari-ethereum-pool-fund do not update _rawFundBalanceCache at all, which is different from the behavior of the same functions in the other repositories: rari-staple-pool-contracts and rari-yield-pool-contracts.

 Recommendation: Clarify if this behavior is intentional. If not, update the _rawFundBalanceCache similarly to the other repos.


###### Update from dev team: Usage of _rawFundBalanceCache was temporarily removed in the Rari Ethereum Pool, but we will be restoring this code in a later version of the contracts.

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

#### The implementation seems to adhere to the specification.

# Code Documentation

#### We have identified the following issues in the code documentation:

 1. Overall more code comments should be used to describe non-trivial lines of code or sequences of lines of code.

 2. [Fixed] L74 in AavePoolController.sol - "dYdX" should be "Aave"

 3. It appears that if (amount > 0 && allowance > 0) token.safeApprove(); is being used to prevent the allowance double-spend exploit in all pool controllers. While

 this may work, the functionality may be unintuitive to the user. The documentation should reflect this approach, which is not common in ERC20 contracts.

 4. [Fixed] L210 in RariFundProxy.sol - "@notice Exchanges and deposits funds to RariFund in exchange for RFT." does not match the function (copy+paste of L149)