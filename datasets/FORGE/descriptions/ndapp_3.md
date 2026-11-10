#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L342,343,348,361

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L342,343,348,361|

```
feeDenominator
busdToken
ZERO
DEAD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

