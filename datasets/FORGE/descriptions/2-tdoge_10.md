#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor / informative

**Location** contract.sol#L2259,2293,2255

**Status** Unresolved

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L2259,2293,2255|
|Status|Unresolved|


DFee
iterations
lastProcessedIndex
fees
claims


##### Recommendation

All the local scoped variables should be initialized.


-----

