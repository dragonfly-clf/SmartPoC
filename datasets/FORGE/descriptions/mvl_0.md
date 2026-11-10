#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1276

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1276|

```
function setTaxFeePercent(uint256 taxFeeBps) external onlyOwner {
  require(taxFeeBps >= 0 && taxFeeBps <= 10**4, "Invalid bps");
  _taxFee = taxFeeBps;
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
|⬤|L07|Missing Events Arithmetic|
|⬤|L08|Tautology or Contradiction|
|⬤|L09|Dead Code Elimination|


-----

