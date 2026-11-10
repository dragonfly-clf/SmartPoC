#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L743

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L743|

```
IUniswapV2Router02 _uniswapV2Router =
IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //0x10ED43C718714eb63d5aA57B78B54704E256024E for mainnet
    //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 for testnet
     // Create a uniswap pair for this new token
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
       .createPair(address(this), _uniswapV2Router.WETH());
    // set the rest of the contract variables
    uniswapV2Router = _uniswapV2Router;

```

##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

