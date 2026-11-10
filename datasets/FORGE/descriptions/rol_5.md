#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L598,599,616,636,983,1052,1058,1064,779,789 and 3 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L598,599,616,636,983,1052,1058,1064,779,789 and 3 more|

```
_maxTxAmount
_liquidityFee
_devmarketingFee
_taxFee
_DevMarketingWalletAddress
_amount
_enabled
WETH
MINIMUM_LIQUIDITY

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

