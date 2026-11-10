#### L11 - Unnecessary Boolean equality

**Criticality** minor / informative

**Location** contract.sol#L1222

**Status** Unresolved

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compared to true or false.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1222|
|Status|Unresolved|


isBot == true


##### Recommendation

Remove the equality to the boolean constant.