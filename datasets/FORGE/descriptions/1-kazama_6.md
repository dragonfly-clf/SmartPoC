#### L11 - Unnecessary Boolean equality

**Criticality** minor / informative

**Location** contract.sol#L1038,1149,955

**Status** Unresolved

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compared to true or false.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1038,1149,955|
|Status|Unresolved|

```
shouldBurnSender(sender) == false
require(bool,string)(BuyBacker[_msgSender()] == true,)

```

##### Recommendation

Remove the equality to the boolean constant.