#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L115

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L115|

```
_tTotal

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

