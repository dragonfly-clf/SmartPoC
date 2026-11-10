#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L2008

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellFees function with
arguments that sum up to 9800. As a result the fees will be 98%.

|Criticality|critical|
|---|---|
|Location|contract.sol#L2008|

```
function setSellFees(
  uint256 liquidityFee,
  uint256 marketingFee,
  uint256 devFee,
  uint256 jackpotFee
) external onlyAuthorized {
  require(
    liquidityFee.add(marketingFee).add(devFee).add(jackpotFee) <=
       TOTAL_FEES_LIMIT,
    "Total fees can not exceed the declared limit"
  );
  sLiquidityFee = liquidityFee;
  sMarketingFee = marketingFee;
  sDevFee = devFee;
  sJackpotFee = jackpotFee;

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|


-----

