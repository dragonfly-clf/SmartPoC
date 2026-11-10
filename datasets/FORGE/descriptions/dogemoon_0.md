#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1496

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setRewardsFee function with a high
percentage value. This can cause the contract to operate similar to a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1496|

```
function setRewardsFee(uint256 _buy, uint256[] memory _sell) external onlyOwner
{
  require(_sell.length == rewardsFee.length-1, "Wrong amount of sell fees
provided");
  rewardsFee = [_buy, _sell[0], _sell[1], _sell[2]];
  require(rewardsFee[0] <= 100 && rewardsFee[1] <= 100 && rewardsFee[2] <= 100
&& rewardsFee[3] <= 100, "Total fee is over 100%");
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
|⬤|FSA|Fixed Swap Address|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L12|Using Variables before Declaration|
|⬤|L14|Uninitialized Variables in Local Scope|
|⬤|L15|Local Scope Variable Shadowing|


-----

