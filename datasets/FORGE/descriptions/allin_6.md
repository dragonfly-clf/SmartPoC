#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L99,197,150,158,159,588,636,645,650,655 and 29 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L99,197,150,158,159,588,636,645,650,655 and 29 more|

```
_allowances
_balances
_maxWalletToken
_maxTxAmount
_totalSupply
_decimals
_symbol
_name
ZERO

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

