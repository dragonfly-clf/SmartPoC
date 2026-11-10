#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L139,242,195,203,204,648 and 30 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L139,242,195,203,204,648 and 30 more|

```
_allowances
_balances
_maxWalletToken

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

