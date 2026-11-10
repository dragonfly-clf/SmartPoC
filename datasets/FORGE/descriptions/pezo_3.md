#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L369,364,366,370,380,423 and 2 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L369,364,366,370,380,423 and 2 more|

```
dividendsPerShareAccuracyFactor
WBNB
launchedAt

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

