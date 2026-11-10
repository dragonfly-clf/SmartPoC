#### FSA - Fixed Swap Address

**Criticality** Minor / Informative

**Location** ZangAi.sol#L409

**Status** Unresolved

#### Description

The swap address is assigned once and it can not be changed. It is a common practice in

decentralized exchanges to create new swap versions. A contract that cannot change the

swap address may not be able to catch up to the upgrade. As a result, the contract will not

be able to migrate to a new liquidity pool pair or decentralized exchange.
```
 constructor () {
   ...
   IUniswapV2Router02 _uniswapV2Router =
 IUniswapV2Router02(router);
   uniswapV2Pair =
 IUniswapV2Factory(_uniswapV2Router.factory())
   .createPair(address(this), _uniswapV2Router.WETH());
   uniswapV2Router = _uniswapV2Router;
   ...
 }

#### Recommendation

```
The team is advised to add the ability to change the pair and router address in order to

cover potential liquidity pool migrations. It would be better to support multiple pair

addresses so the token will be able to have the same behavior in all the decentralized

liquidity pairs.


-----

