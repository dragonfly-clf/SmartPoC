#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L35,L37,L36 and 1 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L35,L37,L36 and 1 more|

```
_totalSupply
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

