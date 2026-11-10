#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L751,739,759,756,746

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L751,739,759,756,746|
|Status|Unresolved|

```
_liquidityFee = liquidityFee
_minTokenBalance = minimumToken
maxWalletToken = _maxToken
_percentageOfLiquidityForMarketing = marketingFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

