#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L194,196,267,268,282,300,633,638,708,714,720,442,450,452,454,46
0

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L194,196,267,268,282,300,633,638,708,714,720,442,450,452,454,46 0|

```
_maxTxAmount
_liquidityFee
_devFee
_taxFee
_devWalletAddress
_amount
_enabled
_addr
WETH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

