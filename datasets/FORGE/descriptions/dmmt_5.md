#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L1308,923,608,942,638,1300,941,931,606,1699,1735,917,920,927,
684

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1308,923,608,942,638,1300,941,931,606,1699,1735,917,920,927, 684|


WETH
_marketingFee
_liquidityFee
_taxFee
_seconds
_enabled
DOMAIN_SEPARATOR
BUSD
_minBuyTxAmount
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

