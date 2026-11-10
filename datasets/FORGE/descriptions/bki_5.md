#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L566,1187,626,627,628,630,631,632,633,637 and 18 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L566,1187,626,627,628,630,631,632,633,637 and 18 more|

```
_liquidityFeeTotal
_taxFeeTotal
_SellecosystemFee
_SellrewardFee
_SelllLiquidityFee
_SellmarketingFee
_SelltaxFee
_ecosystemFee
_rewardFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

