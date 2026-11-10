#### L08 - Tautology or Contradiction

**Criticality** minor / informative

**Location** contract.sol#L572

**Status** Unresolved

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L572|
|Status|Unresolved|


require(bool,string)(index >= 0 && index < fees.length,FeesSettings._getFeeStruct: Fee index out
of bounds)


##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

