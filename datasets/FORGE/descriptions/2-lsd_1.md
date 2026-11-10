#### BC - Blacklists Addresses

**Criticality** medium

**Location** contract.sol#L1222

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklistAddress function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1222|
|Status|Unresolved|

```
function writeBlackList(address BotAddress, bool isBot) external onlyOwner {
  if (isBot == true)
    require(
       BotAddress != mainPair && BotAddress != address(this),
       "You cannot blacklist this address!!"
    );
  blackList[BotAddress] = isBot;
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|


-----

