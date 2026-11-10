### L14 - Uninitialized Variables in Local Scope

**Criticality** Minor / Informative

**Location** TRITON.sol#L1443,1444,1445,1446,1447,1555,1692,1693,1720,2167,222
9

**Status** Unresolved

### Description

Using an uninitialized local variable can lead to unpredictable behavior and potentially

cause errors in the contract. It's important to always initialize local variables with

appropriate values before using them.
```
 uint256 RewardsFee
 uint256 deadFees
 uint256 marketingFees
 uint256 liquidityFee
 uint256 devFees
 uint256 burntokens
 uint256 dividendsFromBuy
 uint256 dividendsFromSell
 uint256 feePortions
 bool success

### Recommendation

```
By initializing local variables before using them, the contract ensures that the functions

behave as expected and avoid potential issues.


-----

