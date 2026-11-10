#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L392,L374,L378 and 3 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L392,L374,L378 and 3 more|

```
numTokensSellToAddToLiquidity
_tTotal
_symbol

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

