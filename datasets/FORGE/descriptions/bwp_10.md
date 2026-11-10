#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L164,166,197,243,737,844,964,981,1262,1263,1264,1265,1273,1279
,1284,1289,1521,1555,883,895,912,913,921,923,924,925,927,928

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L164,166,197,243,737,844,964,981,1262,1263,1264,1265,1273,1279,1284,1289,1521,1555,883,895,912,913,921,923,924,925,927,928|
|Status|Unresolved|

```
DOMAIN_SEPARATOR
PERMIT_TYPEHASH
MINIMUM_LIQUIDITY
WETH
alphabet
IBWORKER_NFT
_flag
_flagAutoMintProfit
_flagAutoAddLiquidity

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

