#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1976,L1984,L1986 and 1 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1976,L1984,L1986 and 1 more|

```
_tokenSupply
_routerAddress
_marketingAddress

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

