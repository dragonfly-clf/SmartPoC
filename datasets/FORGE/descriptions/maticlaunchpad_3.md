#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L758

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L758|

```
IPancakeswapV2Router02 _pancakeRouter =
IPancakeswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
// Create a Pancake pair for this new token
pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeRouter.factory())
  .createPair(address(this), _pancakeRouter.WETH());
// set the rest of the contract variables
pancakeswapV2Router = _pancakeRouter;

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

