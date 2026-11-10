#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L720,902,515,532,723,926,909,717,514,998,918,554,735,993,1003,
732

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L720,902,515,532,723,926,909,717,514,998,918,554,735,993,1003, 732|


_maxTxAmount
_amount
DevAddress
WETH
_address
DOMAIN_SEPARATOR
_taxFee
_enabled
_DevFee
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

