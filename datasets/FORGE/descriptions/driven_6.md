#### L04 - Conformance to Solidity Naming Conventions

###### Criticality minor

 Location contract.sol#L6,1693,1786,1788,1805,1835,2176,2000,2008

##### Description

###### Solidity defines a naming convention that should be followed. Rule exceptions:

 ● Allow constant variable name/symbol/decimals to be lowercase.
 ● Allow _ at the beginning of the mixed_case match for private variables and unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L6,1693,1786,1788,1805,1835,2176,2000,2008|

```
_minimumTokensBeforeSwap
_balances
_enabled
WETH
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH
DOMAIN_SEPARATOR
_owner
console

```

##### Recommendation

###### Follow the Solidity naming convention. https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.


-----

