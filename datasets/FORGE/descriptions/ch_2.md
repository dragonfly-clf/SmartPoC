#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L339

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L339|

```
if(marketingAmount>0){
BUSD.transferFrom(address(_tokenDistributor),marketingAddress,marketingAmount);
}
uint256 amountBUSDLiquidity = BUSDBalance - marketingAmount;
BUSD.transferFrom(address(_tokenDistributor), address(this),
amountBUSDLiquidity);

```

##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

