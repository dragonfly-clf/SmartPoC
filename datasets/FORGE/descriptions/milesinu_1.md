#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L903,L906,L909

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L903,L906,L909|


function setTaxFeePercent(uint256 taxFee) external onlyOwner() {

_taxFee = taxFee;
}
function setDevFeePercent(uint256 DevFee) external onlyOwner() {

_DevFee = DevFee;
}
function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {

_liquidityFee = liquidityFee;
}


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
|⬤|STC|Succeeded Transfer Check|
|⬤|FSA|Fixed Swap Address|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L11|Unnecessary Boolean equality|


-----

