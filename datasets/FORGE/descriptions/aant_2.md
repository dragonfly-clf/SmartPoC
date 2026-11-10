#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L465

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the addToBlackList function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L465|

```
  function transferFrom(address sender, address recipient, uint256 amount)
public virtual override returns (bool) {
    require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "This
address is BlackListed!");
    _transfer(sender, recipient, amount);

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
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L09|Dead Code Elimination|
|⬤|L11|Unnecessary Boolean equality|
|⬤|L12|Using Variables before Declaration|
|⬤|L07|Missing Events Arithmetic|
|⬤|L15|Local Scope Variable Shadowing|
|⬤|L14|Uninitialized Variables in Local Scope|
|⬤|L08|Tautology or Contradiction|
|⬤|L13|Divide before Multiply Operation|


-----

