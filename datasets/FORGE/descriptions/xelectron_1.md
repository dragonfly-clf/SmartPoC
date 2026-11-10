#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0xf59bd06F5640dAdd39E17755A1D00d4F3B9653
27#codeL573

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellTaxes function with a high
percentage value.

If the _totalTaxIfSelling is set to very high value, the contract will behave like a
honeypot since the holders will be able to selling their tokens for and getting
nothing, while buying will still be enabled (honeypot-behaviour)

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xf59bd06F5640dAdd39E17755A1D00d4F3B9653 27#codeL573|

```
  function setSellTaxes(uint256 newLiquidityTax, uint256 newMarketingTax,
uint256 newTeamTax) external onlyOwner() {
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


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

