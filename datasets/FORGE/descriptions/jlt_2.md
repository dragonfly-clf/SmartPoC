#### ULF - Unused Liquidity Functionality

**Criticality** Minor / Informative

**Location** JLT.sol#L1002

**Status** Unresolved

#### Description

The contract contains the `addLiquidity` function designed to facilitate the addition of

liquidity to a Uniswap V2 pool by approving token transfers and interacting with the

UniswapV2Router's `addLiquidityETH` method. The function is marked as private,

indicating that it can only be called from within the contract itself. Despite its presence and

the potential utility it offers for liquidity management, the `addLiquidity` function is

never invoked in any part of the contract's code. This omission results in the liquidity

addition functionality being effectively dormant and unutilized within the contract's

operational framework.
```
   function addLiquidity(uint256 tokenAmount, uint256
 ethAmount) private {
      // approve token transfer to cover all possible
 scenarios
      _approve(address(this), address(uniswapV2Router),
 tokenAmount);
      // add the liquidity
      uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(this),
        tokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        deadAddress,
        block.timestamp
      );
   }

#### Recommendation

```
It is recommended to reconsider the contract's code implementation concerning the

`addLiquidity` function. If the intended functionality of the contract includes the

capability to add liquidity to a Uniswap V2 pool, it is crucial to ensure that the


-----

`addLiquidity` function is appropriately integrated and utilized within the contract's

workflow. This integration may involve adding calls to addLiquidity at relevant points in the

contract or developing additional functions that leverage this capability for liquidity

management purposes. Conversely, if the addition of liquidity is not a required feature for

the contract's intended operations, it may be prudent to remove the `addLiquidity`

function from the codebase. This action would streamline the contract, eliminating

unnecessary code and reducing potential confusion regarding the contract's capabilities

and intended use cases.


-----

