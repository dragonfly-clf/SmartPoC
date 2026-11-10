#### BC - Blacklisted Contracts

**Criticality** medium

**Location** https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc
#L1182

**Status** Multi-Sign

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the setBlackList function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc #L1182|
|Status|Multi-Sign|

```
function setBlackList(address addr, bool value) external onlyOwner {
  _isBlackListed[addr] = value;
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 17 May 2022

The team has acknowledged the threat and transferred the contract ownership to a
multi-sign mechanism.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

