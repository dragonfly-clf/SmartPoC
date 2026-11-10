#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L217,501,639,504,222,640,499,214

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L217,501,639,504,222,640,499,214|
|Status|Unresolved|


_mainnetRouterV2Address
projectAddress
_name
burnAddress
_testnetRouterAddress
_symbol
priceAddress
_mainnetRouterV1Address


##### Recommendation

Add the constant attribute to state variables that never change.


-----

