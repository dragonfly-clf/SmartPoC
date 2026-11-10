#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L501,480,478,479,515

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L501,480,478,479,515|

```
_tTotal
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

