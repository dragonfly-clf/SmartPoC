#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L573,567,579,551,554,372,389,565,577,371,578,580,409,759,566

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L573,567,579,551,554,372,389,565,577,371,578,580,409,759,566|
|Status|Unresolved|

```
_maxTxAmount
_percentageOfLiquidityForMarketing
_uniswapV2Router
_isExcludedFromAutoLiquidity
_marketingWallet
PERMIT_TYPEHASH
MINIMUM_LIQUIDITY
_taxFee
_swapAndLiquifyEnabled

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

