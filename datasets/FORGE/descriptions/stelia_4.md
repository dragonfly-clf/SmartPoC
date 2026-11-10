#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L502,500,523,498,505,499,494

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L502,500,523,498,505,499,494|


_tTotal
_symbol
_sellTaxFee
_name
_maxTxAmount
_decimals
_buyTaxFee


##### Recommendation

Add the constant attribute to state variables that never change.


-----

