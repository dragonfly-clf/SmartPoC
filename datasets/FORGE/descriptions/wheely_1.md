#### RSML - Redundant SafeMath Library

**Criticality** minor / informative

**Location** contract.sol#L18

**Status** Unresolved

##### Description

The Solidity versions that are greater than or equal to 0.8.0 do not need the use of
SafeMath Library. The usage of the SafeMath library produces unnecessary
additional gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L18|
|Status|Unresolved|


library SafeMath {
…
}


##### Recommendation

The team is advised to remove the SafeMath library as it is safe to do math
operations without it.


-----

