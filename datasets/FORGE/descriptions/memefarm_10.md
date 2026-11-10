#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L151,168,177,163,161,160,157,341,165,167,153,172,148,164,159,1
69,171,173,122,176

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L151,168,177,163,161,160,157,341,165,167,153,172,148,164,159,1 69,171,173,122,176|


_maxTxAmount
WETH
_totalDistributionShares
_totalTaxIfBuying
_teamShare
_balances
_buyLiquidityFee
_sellMarketingFee
________
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

