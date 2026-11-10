#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L383

**Status** Ownership renounced

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellLPFee function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L383|
|Status|Ownership renounced|

```
function setSellLPFee(uint256 lpFee) external onlyOwner {
  _sellLPFee = lpFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Update 11/07

The contract has renounced the ownership, as a result the methods cannot be
abused.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|STC|Succeeded Transfer Check|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L06|Missing Events Access Control|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

