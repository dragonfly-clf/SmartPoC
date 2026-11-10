#### ELFM - Exceeds Fees Limit

**Criticality** critical

**Location** contract.sol#L731

**Status** Unresolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTax function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L731|
|Status|Unresolved|

```
function setTax(uint256 _sellTaxFee, uint256 _buyTaxFee) public onlyOwner{
  sellTaxFee = _sellTaxFee;
  buyTaxFee = _buyTaxFee;
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

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|TSD|Total Supply Diversion|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|


-----

