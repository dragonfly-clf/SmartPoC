#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L714

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The contract swaps the tokens to receive ETH twice. Once for the auto generated
liquidity pool and once for the sending funds to the team’s wallets.

|Criticality|minor|
|---|---|
|Location|contract.sol#L714|

```
swapTokensForEth(halfLiquidityTokens);
uint256 newBalance = address(this).balance.sub(initialBalance);
addLiquidity(halfLiquidityTokens, newBalance);
emit SwapAndLiquify(halfLiquidityTokens, newBalance, halfLiquidityTokens);
initialBalance = address(this).balance;
uint256 totalTokens = balanceOf(address(this));
swapTokensForEth(totalTokens);
newBalance = address(this).balance.sub(initialBalance);
uint256 walletsTotal =
devTokensCollected.add(marketingTokensCollected).add(buybackTokensCollected);
uint256 ethForMarketing =
newBalance.mul(marketingTokensCollected).div(walletsTotal);
uint256 ethForBuyback =
newBalance.mul(buybackTokensCollected).div(walletsTotal);
uint256 ethForDev = newBalance.mul(devTokensCollected).div(walletsTotal);
transferToAddressETH(marketingWalletAddress, ethForMarketing);
transferToAddressETH(buybackWalletAddress, ethForBuyback);
transferToAddressETH(devWalletAddress, ethForDev);

```

##### Recommendation


-----

Rewrite some code segments so the runtime will be more performant. The contract
could swap once the entire amount and distribute the proportional amount.


-----

