#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L154,245,246,263,285,608,616,684,690,696 and 3 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L154,245,246,263,285,608,616,684,690,696 and 3 more|

```
_liquidityFee
_Marketing
_taxFee
_amount
_enabled
Marketing
WETH
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

