#### BLC - Business Logic Concern

**Criticality** minor

**Location** contract.sol#L588, 725, 1066

##### Description

The business logic seems peculiar. The implementation may not follow the expected
behavior. In the following code segments, the contract checks if the account
address that is passed in the excludeAccount function is different from the initial
value of the liquidityAddress.

|Criticality|minor|
|---|---|
|Location|contract.sol#L588, 725, 1066|

```
address public liquidityAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
// PancakeSwapRouterV2

```
```
function excludeAccount(address account) external onlyOwner() {
  require(account != 0x10ED43C718714eb63d5aA57B78B54704E256024E,"CHAR:
Uniswap router cannot be excluded.");

```

But the user has the authority to change this address by calling the
setLiquidityAddress.

```
function setLiquidityAddress(address _Address) public onlyOwner {
  require(_Address != liquidityAddress);
  liquidityAddress = _Address;
}

```

##### Recommendation

The team is advised to carefully check if the implementation follows the expected
business logic.


-----

