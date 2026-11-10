#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L646

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L646|

```
router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    pair = IUniswapV2Factory(router.factory()).createPair(
       WBNB,
       address(this)
    );

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

