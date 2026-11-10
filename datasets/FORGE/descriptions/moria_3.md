#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L426,L431,L430 and 2 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L426,L431,L430 and 2 more|

```
_tTotal
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

