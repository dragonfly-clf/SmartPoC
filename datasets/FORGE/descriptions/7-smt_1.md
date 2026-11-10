#### RSML - Redundant SafeMath Library

**Criticality** minor / informative

**Location** contract.sol#L49

**Status** Unresolved

##### Description

Solidity versions greater than or equal to 0.8.0 no longer need the use of SafeMath
Library.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L49|
|Status|Unresolved|


library SafeMath {

…..
}


##### Recommendation

The team is advised to remove this library as it is safe to do math operations without
it.


-----

