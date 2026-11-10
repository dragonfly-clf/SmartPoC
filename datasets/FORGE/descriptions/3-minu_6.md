#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L502,522,523,540,562,802,935,998,718,739,740

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L502,522,523,540,562,802,935,998,718,739,740|

```
marketing_address
_timeLimit
_fee
_amount
_enabled
_address
WETH
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

