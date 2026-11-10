#### ELFM - Exceeds Fees Limit

|Criticality|critical|
|---|---|
|Location|DiamondDexToken.sol#L1168,1172,1180|
|Status|renounced|


##### Description


The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the following functions with a high
percentage value:

 - setTaxFeePercent()

 - setLiquidityFeePercent()

 - setMarketingFeePercent()


##### Recommendation


The contract could embody a check for the maximum acceptable value.


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

##### Team Update


The team renounced ownership in the following transaction:
[https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)
[d653cca5c0389219](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)


The fees are locked in the following values:



- taxFee: 3

- liquidityFee: 2

- marketingFee: 10


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PVC|Price Volatility Concern|renounced|
|⬤|RSML|Redundant SafeMath Library|unresolved|
|⬤|L02|State Variables could be Declared Constant|unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|unresolved|
|⬤|L07|Missing Events Arithmetic|unresolved|
|⬤|L09|Dead Code Elimination|unresolved|
|⬤|L10|State Variables in Loop|unresolved|


-----

