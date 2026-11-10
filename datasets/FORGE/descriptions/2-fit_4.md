#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L1598

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1598|


Fitness Token
IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(

newRouter // address uniswap
);
uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())

.createPair(address(this), _uniswapV2Router.WETH());
uniswapV2Router = _uniswapV2Router;


##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

