#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L725,L715,L695 and 3 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L725,L715,L695 and 3 more|

```
numTokensSellToAddToLiquidity
marketingWallet
_tTotal

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

