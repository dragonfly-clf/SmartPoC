#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L72

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L72|

```
_previousOwner

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

