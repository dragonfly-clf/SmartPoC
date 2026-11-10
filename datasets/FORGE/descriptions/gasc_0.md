#### OCTD - Owner Contract Tokens Drain

**Criticality** critical

**Location** https://bscscan.com/address/0x62bC448A508499fb54479CC7a6fA79C2D8f16c
De#contracts#L388

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the manualsend function. The owner is
also draining all the contract balance passively as 100% of the tokens accumulated
gets split into marketing and dev wallets.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x62bC448A508499fb54479CC7a6fA79C2D8f16c De#contracts#L388|

```
  function manualsend() external {
    require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
    uint256 contractETHBalance = address(this).balance;
    sendETHToFee(contractETHBalance);
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


-----

