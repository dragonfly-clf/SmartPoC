#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor / informative

**Location** contract.sol#L515,281,280,346,538

**Status** Unresolved

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L515,281,280,346,538|
|Status|Unresolved|


i
isSell
takeFee
feeAmount


##### Recommendation

All the local scoped variables should be initialized.