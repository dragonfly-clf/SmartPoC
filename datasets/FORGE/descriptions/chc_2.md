#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L587,L581,L589 and 5 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L587,L581,L589 and 5 more|

```
teamAddress
presaleAddress
marketingAddress

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

