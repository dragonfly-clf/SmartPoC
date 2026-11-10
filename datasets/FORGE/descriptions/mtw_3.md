#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L721,L705,L710 and 2 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L721,L705,L710 and 2 more|

```
deadAddress
_tTotal
_symbol

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

