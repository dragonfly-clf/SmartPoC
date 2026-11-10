#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L615,795,799

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L615,795,799|

```
marketingDivisor
_rateLimitSeconds
lastAmount

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

