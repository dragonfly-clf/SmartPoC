#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L215,216,230,248,598,606,664,669,674,387,395,397,399,417,815

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L215,216,230,248,598,606,664,669,674,387,395,397,399,417,815|

```
_isBlacklisted
_maxTxAmount
_liquidityFee
_DevWalletFee
_taxFee
_DevWalletWalletAddress
_amount
_enabled
DevWalletFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

