#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L1

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1|

```
    IUniswapV2Router02 _uniswapV2Router =
IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

