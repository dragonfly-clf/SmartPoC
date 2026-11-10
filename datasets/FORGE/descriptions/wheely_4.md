#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L638

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L638|
|Status|Unresolved|


fee = amount / 10000 * 1


##### Recommendation

The multiplications should be prior to the divisions.