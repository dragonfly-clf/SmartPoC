#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L450,L433,L432 and 1 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L450,L433,L432 and 1 more|

```
maxTimeStakeCluster
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

