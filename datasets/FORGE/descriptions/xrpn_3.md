#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L311,L306,L304 and 3 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L311,L306,L304 and 3 more|

```
_totalSupply
ZERO
WBNB

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

