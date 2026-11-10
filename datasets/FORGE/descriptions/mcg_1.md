#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1774

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the updateFees function with a high 20,
20, 50, 50. As a result the total taxes will be increased to 90%.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1774|

```
function updateFees(
  uint256 operations,
  uint256 liquidity,
  uint256 MCGRewardsBuy,
  uint256 MCGRewardsSell
) public onlyOwner {
  require(operations <= 20, "operation fees can't exceed 20%");
  require(liquidity <= 20, "liquidity fees can't exceed 20%");
  require(
    MCGRewardsBuy >= 1 && MCGRewardsBuy <= 50,
    "MCG reward fees must be between 1 and 50"
  );
  require(
    MCGRewardsSell >= 1 && MCGRewardsSell <= 50,
    "MCG reward fees must be between 1 and 50"
  );
  operationsFees = operations;
  liquidityFee = liquidity;
  MCGRewardsBuyFee = MCGRewardsBuy;
  MCGRewardsSellFee = MCGRewardsSell;
  totalSellFees = MCGRewardsSellFee.add(liquidityFee).add(operationsFees);
  totalBuyFees = MCGRewardsBuyFee.add(liquidityFee).add(operationsFees);
  emit UpdateFees(operations, liquidity, MCGRewardsBuy, MCGRewardsSell);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.


-----

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
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L12|Using Variables before Declaration|
|⬤|L13|Divide before Multiply Operation|
|⬤|L14|Uninitialized Variables in Local Scope|
|⬤|L15|Local Scope Variable Shadowing|


-----

