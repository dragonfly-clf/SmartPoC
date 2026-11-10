#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L637,648

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it in many ways. For instance, by adding
the address to the boe or by increasing one of the variants that increase the SAT
timer.

|Criticality|critical|
|---|---|
|Location|contract.sol#L637,648|

```
} else if (to == uniswapV2Pair) {
    require(!boe[from]);
    if (nwtbs > 0 || wttsai2 > 0) {
       require(block.timestamp > SAT[from]);
    }

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the
```
Public_Trading_Enabled to false.

```
```
require(Public_Trading_Enabled || ieff[from] || ieff[to],
    "Public Trading has not been enabled yet.");

```

##### Recommendation

The contract could embody a check for not allowing setting the
Public_Trading_Enabled to false after the initial toggle. The contract should not allow
to timelock the addresses more than a reasonable time period.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

