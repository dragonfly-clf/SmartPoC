#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L477,770,776,782,828,504,505,509,510,522,527

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L477,770,776,782,828,504,505,509,510,522,527|

```
_maxTxAmount
_advestisementFee
_sellAdvestisementFee
_sellTaxFee
_buyAdvestisementFee
_buyTaxFee
_airdropContract
_amount
WETH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

