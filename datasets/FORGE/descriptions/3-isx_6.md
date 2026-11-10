#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L2244,1128,1150,1144,1122,1075,1169,1562,2240,1135,1165,1681
,1677,1164,1076,1147,1132,2228,2338,1138,1129,847,1535,1141,2232

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2244,1128,1150,1144,1122,1075,1169,1562,2240,1135,1165,1681,1677,1164,1076,1147,1132,2228,2338,1138,1129,847,1535,1141,2232|


_owner
_burnFee
_enabled
WETH
_symbol
_liquidityFee
_account
_taxFee
_walletCharityFee
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

