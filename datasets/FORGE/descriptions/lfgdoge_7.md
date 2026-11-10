#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L213,214,230,249,563,699,394,403,405,408 and 1 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L213,214,230,249,563,699,394,403,405,408 and 1 more|

```
_walletMax
_maxTxAmount
_totalTax
_marketingFee
_balances
_account
_enabled
WETH
MINIMUM_LIQUIDITY

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

