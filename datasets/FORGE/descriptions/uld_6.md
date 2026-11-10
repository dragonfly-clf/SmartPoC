#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L496,513,698,495,899,707,969,394,695,535,963

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L496,513,698,495,899,707,969,394,695,535,963|


_amount
WETH
_taxFee
_owner
_maxTxAmount
_enabled
DOMAIN_SEPARATOR
_liquidityFee
MINIMUM_LIQUIDITY
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

