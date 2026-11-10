#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L275,519,521,552,2060,2061,2062,2091,2092,2112,1693,1694,1695,
1696

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L275,519,521,552,2060,2061,2062,2091,2092,2112,1693,1694,1695, 1696|

```
_tTotal
_decimals
_symbol
_name
_jackpotTimespan
_jackpotHardLimit
_jackpotHardBuyback
_jackpotMinBuy
_jackpotBuyerShare

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

