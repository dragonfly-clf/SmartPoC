#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L107,242,246,347,357,365,419,425,436,443,450,457,469,476,481,1
30,131,132,134,135,136,138,140,141,143,144,158

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L107,242,246,347,357,365,419,425,436,443,450,457,469,476,481,1 30,131,132,134,135,136,138,140,141,143,144,158|

```
feeDenominator
_allowances
_balances
_maxWalletToken
_maxTxAmount
_totalSupply
_decimals
_symbol
_name

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

