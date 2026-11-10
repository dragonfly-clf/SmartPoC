#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L617

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L617|

```
    IPancakeRouter02 _pancakeswapV2Router =
IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
     // Create a uniswap pair for this new token
    pcsV2Pair =
IPancakeFactory(_pancakeswapV2Router.factory()).createPair(address(this),
_pancakeswapV2Router.WETH());

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

