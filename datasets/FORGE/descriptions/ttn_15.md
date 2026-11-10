### UCL - Unoptimized Calculation Logic

**Criticality** Minor / Informative

**Location** TRITON.sol#L1529

**Status** Unresolved

### Description

The contract is currently structured to perform separate calculations for buy and sell fees,

subsequently adding these amounts together to determine the total swap tokens.

Specifically, it calculates `swapAmountBought` and `swapAmountSold` based on the

`buyAmount` and `sellAmount` respectively, and then applies the liquidity fee to each

to obtain `swapBuyTokens` and `swapSellTokens` . These two values are then

added to get the total `swapTokens` . This approach, while functional, introduces

unnecessary complexity and redundancy in calculations, especially considering that the

same end result could be achieved with a more streamlined process.


-----

### Recommendation

It is recommended to simplify the calculation process by applying the liquidity fee

calculation directly to the `totalBuySell` value, which represents the sum of

`buyAmount` and `sellAmount` . This approach would eliminate the need for separate

calculations for buy and sell amounts, thereby reducing computational overhead and

potential for errors. By directly using the `totalBuySell` value, the contract can more

efficiently calculate the total `swapTokens` needed for the `swapAndLiquify`

function. This optimization not only streamlines the code but also potentially reduces gas

costs associated with these calculations, enhancing the overall efficiency and performance

of the contract.


-----

