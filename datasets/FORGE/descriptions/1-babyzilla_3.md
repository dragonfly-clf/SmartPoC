#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L2000,1999,1997,1988

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2000,1999,1997,1988|

```
_tokenSupply
_routerAddress
_marketingAddress
_buyBackAddress

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

