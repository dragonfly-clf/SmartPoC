#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L1455,97,1719,827,108,844,1454,1433,157,1905,826,1107,2181,19
04,1910,1102,88,1409,1515,1534,1907,1456,1522,113,662,1903,1548,84,1453

###### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1455,97,1719,827,108,844,1454,1433,157,1905,826,1107,2181,19 04,1910,1102,88,1409,1515,1534,1907,1456,1522,113,662,1903,1548,84,1453|


__DividendPayingToken_init
__Context_init
_owner
AmountLiquidityFee
WETH
__Ownable_init_unchained
_symbol
_marketingWalletAddress
__gap
...


###### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

