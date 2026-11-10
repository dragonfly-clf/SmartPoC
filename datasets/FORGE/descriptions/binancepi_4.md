#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L234,235,251,270,621,413,416,434,441,442

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L234,235,251,270,621,413,416,434,441,442|

```
_walletMax
_maxTxAmount
_LPADShare
_balances
LPAd
_enabled
WETH
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

