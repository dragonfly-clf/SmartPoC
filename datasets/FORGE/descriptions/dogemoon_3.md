#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L2014,2016,2015,2005

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2014,2016,2015,2005|

```
_tokenSupply
_routerAddress
_rewardToken
_owner

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

