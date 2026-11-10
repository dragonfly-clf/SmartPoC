#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L1485

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the setBlackList function. Additionally, the
contract is blacklisting all the addresses that bought in less than 100 blocks after
the trading open.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1485|

```
require(
  !_isBlackListed[from] && !_isBlackListed[to],
  "Account is blacklisted"
);

```
```
if (block.number < tradingStartBlock + BLOCKCOUNT) {
  _isBlackListed[to] = true;
}

```

##### Recommendation

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
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

