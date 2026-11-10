#### EPC - Existing Pair Creation

**Criticality** Minor / Informative

**Location** CiccaDefi.sol#L1151

**Status** Unresolved

#### Description

The contract contains the `setRouterAddress` function that does not handle the

scenario where a pair already exists prior to its execution. If a pair for the given tokens has

already been established, the `createPair` function will revert and not proceed with the

creation of a new pair. As a result, if a pair has been previously set up before the function is

invoked, the contract will encounter an error when trying to call the `createPair`

function. This will prevent the successful execution, essentially leading the function to

revert.
```
   function setRouterAddress(address newRouter) public onlyOwner()
 {
      IUniswapV2Router02 _newPancakeRouter =
 IUniswapV2Router02(newRouter);
      uniswapV2Pair =
 IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(t
 his), _newPancakeRouter.WETH());
      uniswapV2Router = _newPancakeRouter;
   }

#### Recommendation

```
To mitigate the risks associated with attempting to create an already existing pair, it is

recommended to implement a check to determine whether the pair already exists before

proceeding to create a new pair. This can be achieved by utilizing the getPair function of the

Factory contract to retrieve the address of the pair contract for the specified tokens. If the

address returned by the getPair function is the zero address, it indicates that the pair does

not exist, and the contract can proceed with the createPair function. Conversely, if a

non-zero address is returned, it indicates that the pair already exists, and the createPair

function will revert.


-----

