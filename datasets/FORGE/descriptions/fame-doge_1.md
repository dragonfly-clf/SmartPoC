#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L553

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSelTaxes function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L553|

```
function setSelTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256
newTeamTax) external onlyOwner() {
  _sellLiquidityFee = newLiquidityTax;
  _sellMarketingFee = newMarketingTax;
  _sellTeamFee = newTeamTax;
  _totalTaxIfSelling =
_sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 17 March

The team has transferred ownership to the dead address, and the issue has been
resolved.


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


-----

