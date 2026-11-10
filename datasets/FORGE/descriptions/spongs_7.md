#### L11 - Unnecessary Boolean equality

**Criticality** minor

**Location** contract.sol#L1684,L860

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compared to true or false.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1684,L860|

```
require(bool,string)(isAMMWhitelisted(ammContractAddress) == true,SPONGS:
setRewardToken:: AMM is not whitelisted!)
userHasCustomRewardToken[holder] == true

```

##### Recommendation

Remove the equality to the boolean constant.


-----

