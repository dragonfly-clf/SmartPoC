#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L737

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert. This may happen if someone transfers $DOXI tokens to the
contract right after a swapAndLiquify() event.

|Criticality|critical|
|---|---|
|Location|contract.sol#L737|
|Status|Unresolved|

```
uint256 walletsTotal = devTokensCollected + marketingTokensCollected +
charityTokensCollected + reserveTokensCollected;
uint256 ethForMarketing = (newBalance * marketingTokensCollected)/walletsTotal;

```

##### Recommendation

The contract should prevent those variables to be set to zero or should not allow
executing the corresponding statements.


-----

