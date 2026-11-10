#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L641,1075,1292,1427,1431,1439,956,959,962,967

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L641,1075,1292,1427,1431,1439,956,959,962,967|

```
_charityAddress
_charityFee
_liquidityFee
_taxFee
_amount
_enabled
_enable
WETH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

