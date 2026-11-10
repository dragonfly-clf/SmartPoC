#### L11 - Unnecessary Boolean equality

**Criticality** minor

**Location** contract.sol#L161,L128

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compare to true or false.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,L128|

```
require(bool)(tokenBlacklist[msg.sender] == false)

```

##### Recommendation

Remove the equality to the boolean constant.