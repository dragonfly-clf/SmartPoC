#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L218,L205,L371 and 4 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L218,L205,L371 and 4 more|

```
dividendsPerShareAccuracyFactor
WBNB
_totalSupply

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

