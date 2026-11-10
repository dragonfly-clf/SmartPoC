#### ALBN - Add Liquidity Balance Normalisation

**Criticality** minor / informative

**Location** contract.sol#L1079

**Status** Unresolved

##### Description

When the liquidity amount is more than the contract’s balance, then the contract
could liquidate the difference instead of preventing the liquitation.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1079|
|Status|Unresolved|

```
if (
  lqBNBAmount == 0 ||
  lqTokenAmount == 0 ||
  bnbForAddLiquidity == 0 ||
  address(this).balance < bnbForAddLiquidity
) {
  return;
}

```

##### Recommendation

The contract could liquidate the difference of bnbForAddLiquidity ```
address(this).balance instead of preventing the execution.

```

-----

