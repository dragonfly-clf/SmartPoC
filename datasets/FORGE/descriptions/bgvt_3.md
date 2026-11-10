#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L138,137,152,161,163

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L138,137,152,161,163|
|Status|Unresolved|


swapEnabled
tradingEnabled
_tTotal
deadline
deadWallet


##### Recommendation

Add the constant attribute to state variables that never change.


-----

