#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L479,774,780,786,824,505,506,507,509,510,511,522,527,533

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L479,774,780,786,824,505,506,507,509,510,511,522,527,533|


BUSD
_maxTxAmount
_advestisementFee
_sellBurnFee
_sellAdvestisementFee
_sellTaxFee
_buyBurnFee
_buyAdvestisementFee
_buyTaxFee
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

