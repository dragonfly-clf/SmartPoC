#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L356,357,373,395,535,539,901,1140,815

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L356,357,373,395,535,539,901,1140,815|

```
USDT
BigSellAmount
USDCRewardsFee
_totalSupply
_balances
WETH
MUM_LIQUIDITY
PERMIT_TYPEHASH
DOMAIN_SEPARATOR

```

##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

