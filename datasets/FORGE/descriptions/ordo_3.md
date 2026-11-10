#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L200,L250,L249 and 6 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L200,L250,L249 and 6 more|

```
maxPercent
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

