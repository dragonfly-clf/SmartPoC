#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L1136

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1136|

```
uniswapV2Router = IUniswapV2Router02(routerAddress);
    uniswapV2Pair =
IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),
uniswapV2Router.WETH());
    _approve(address(this), address(uniswapV2Router), ~uint256(0));

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

