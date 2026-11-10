#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L554

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by enabling the rocketFuel variable and setting the
```
maxFuelPrice to zero simultaneously.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L554|

```
if(rocketFuel){
  require(!isSniper[sender],"Bots cant sell");
  if(tx.gasprice > maxFuelPrice && sender == pair){
    isSniper[recipient] = true;
    isDividendExempt[recipient] = true;
    emit RocketFuelCheckin(recipient, tx.gasprice);
  }
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
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|
|⬤|L06|Missing Events Access Control|


-----

