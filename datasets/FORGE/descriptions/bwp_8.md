#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L883,886,887,900,916,904,898,902,896

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L883,886,887,900,916,904,898,902,896|
|Status|Unresolved|

```
DECIMALS
_name
_symbol
buyBackReceiver
feeDenominator
gameHolderAddress
insuranceReceiver
profitHolderAddress
treasuryReceiver

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

