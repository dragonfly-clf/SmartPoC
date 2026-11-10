#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L281,285,289,294,212,222,369,370,387,407 and 27 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L281,285,289,294,212,222,369,370,387,407 and 27 more|

```
_buybackFeeSell
_marketingFeeSell
_LpFeeSell
_busdDividendRewardsFeeSell
_buybackFeeBuy
_LpFeeBuy
_marketingFeeBuy
_busdDividendRewardsFeeBuy
_dividendAddress

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

