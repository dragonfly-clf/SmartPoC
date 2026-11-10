#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L655,654,624,644,664,622,623,637

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L655,654,624,644,664,622,623,637|

```
_tokenTotal
_symbol
_name
_liquidityFeeTotal
_feeDecimal
_decimals
_SellrewardFee
_SellecosystemFee

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

