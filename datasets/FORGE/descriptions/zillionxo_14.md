#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L666

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L666|
|Status|Unresolved|


unitBalance = deltaBalance / (denominator - temp.liquidity)


##### Recommendation

The multiplications should be prior to the divisions.