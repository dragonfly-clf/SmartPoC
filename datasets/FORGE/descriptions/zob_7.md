#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L148,149,150,151,141,143,144,146,246,247 and 106 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L148,149,150,151,141,143,144,146,246,247 and 106 more|

```
ExceptAccounts
minAmountTokens_ProjectFundingSwap
Project_Funding_Swap_Mode
Public_Trading_Enabled
Blockchain_Managers_Count
Marketing_Managers_Count
Blockchain_Manager
Marketing_Manager
SAT

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

