#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L841,846,851,856

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setMarketingFee function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L841,846,851,856|

```
function setMarketingFee(uint256 value) external onlyOwner{
  marketingFee = value;
  totalFees =
BUSDRewardsFee.add(liquidityFee).add(marketingFee).add(developerFee);
}

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
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L12|Using Variables before Declaration|
|⬤|L07|Missing Events Arithmetic|
|⬤|L15|Local Scope Variable Shadowing|
|⬤|L14|Uninitialized Variables in Local Scope|
|⬤|L13|Divide before Multiply Operation|


-----

