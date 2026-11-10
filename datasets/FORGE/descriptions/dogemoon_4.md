#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L844,845,862,887,1266,1273,1280,1289,1186,1440 and 4 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L844,845,862,887,1266,1273,1280,1289,1186,1440 and 4 more|

```
_account
_sell
_buy
_secondPeriod
_firstPeriod
magnitude
_owner
WETH
MINIMUM_LIQUIDITY

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

