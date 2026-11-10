#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L703,738,694,702,693,695,698,704

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L703,738,694,702,693,695,698,704|
|Status|Unresolved|


_symbol
numTokensSellToAddToLiquidity
_moonWalletAddress
_name
_developmentWalletAddress
_moonJPAddress
_tTotal
_decimals


##### Recommendation

Add the constant attribute to state variables that never change.


-----

