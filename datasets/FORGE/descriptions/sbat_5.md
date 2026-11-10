#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L613,614,631,651,850,1033,1117,1123,1129,1135,834

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L613,614,631,651,850,1033,1117,1123,1129,1135,834|

```
_maxTxAmount
_amount
_enabled
_burn
WETH
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH
DOMAIN_SEPARATOR

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

