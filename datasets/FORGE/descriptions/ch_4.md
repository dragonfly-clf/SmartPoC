#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L126,125,133

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L126,125,133|

```
sharetotal
router
BUSDaddress

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

