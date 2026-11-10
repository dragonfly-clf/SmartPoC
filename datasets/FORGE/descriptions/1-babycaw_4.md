#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L260,261,277,298,615,619,896,900,976,980,985,990,995,471,474,47
7,480,483,488,489,490,491,492

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L260,261,277,298,615,619,896,900,976,980,985,990,995,471,474,47 7,480,483,488,489,490,491,492|

```
_saleBuybackFee
_saleMarketingFee
_saleDevFee
_saleLiquidityFee
_saleTaxFee
_buybackFee
_marketingFee
_devFee
_liquidityFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

