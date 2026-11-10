#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L610,637,647,206,641,612,611,629,639,606

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L610,637,647,206,641,612,611,629,639,606|
|Status|Unresolved|


_name
DevFeeWallet
numTokensSellToAddToLiquidity
_previousOwner
BurnFeeWallet
_decimals
_symbol
TotalTax
MarketingFeeWallet
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

