#### L11 - Unnecessary Boolean equality

**Criticality** minor

**Location** contract.sol#L527

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compared to true or false.

|Criticality|minor|
|---|---|
|Location|contract.sol#L527|

```
require(bool,string)(txLimitEnable == false || (amount <= maxTxAmount ||
isTxLimitExempt[sender]),TX Limit Exceeded)

```

##### Recommendation

Remove the equality to the boolean constant.


-----

