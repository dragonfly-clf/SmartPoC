#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L11,289,291,322,1366,1260,1270,1272

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L11,289,291,322,1366,1260,1270,1272|

```
_isBlackListed
_devWallet
deadWallet
_token
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH
DOMAIN_SEPARATOR
WETH

```

##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

