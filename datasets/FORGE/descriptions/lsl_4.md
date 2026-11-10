#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L494,L459,L413 and 7 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L494,L459,L413 and 7 more|

```
tradingOpen
deadBlocks
_totalSupply

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

