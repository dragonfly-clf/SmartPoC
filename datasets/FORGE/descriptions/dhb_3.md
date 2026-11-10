#### MC - Missing Check

**Criticality** medium

**Location** contract.sol#L1044,744

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.
###### If _buyBackTimeInterval or _buyBackMaxTimeForHistories are greater than
block.timestamp then the transaction will revert.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1044,744|

```
uint256 startTime = block.timestamp - _buyBackTimeInterval;
uint256 maxStartTimeForHistories = block.timestamp _buyBackMaxTimeForHistories;

```

##### Recommendation

The contract should properly check the variables according to the required
specifications.


-----

