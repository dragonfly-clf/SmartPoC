#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L836,605

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L836,605|
|Status|Unresolved|

```
FeeDenominator
WBNB

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

