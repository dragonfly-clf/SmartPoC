#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L636,641,646

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setDevFeePercent function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L636,641,646|

```
function setDevFeePercent(uint256 devFee) external onlyOwner() {
    _devFee = devFee;
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
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|
|⬤|L13|Divide before Multiply Operation|


-----

