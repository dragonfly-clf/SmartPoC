#### RLF - Redundant Liquidity Feature

**Criticality** Minor / Informative

**Location** ZangAi.sol#L709

**Status** Unresolved

#### Description

The smart contract code includes a liquidity mechanism that is intended to take a portion of

each transaction, represented by `liquidityFeeonBuy` and `liquidityFeeonSell`

, and add it to a liquidity pool. The `liquidityShare` is calculated as the sum of

`liquidityFeeonBuy` and `liquidityFeeonSell, and if` `liquidityShare` is

greater than 0, a corresponding number of tokens are converted into liquidity tokens via the

`swapAndLiquify` function.

However, both the `liquidityFeeonBuy` and `liquidityFeeonSell` are initialized

to 0 in the constructor and are never updated in the contract. This means that

`liquidityShare` will always be 0, and the condition `liquidityShare > 0` will

never be true. As a result, the `swapAndLiquify` function will never be called, and the

liquidity mechanism will never be activated.

This can lead to confusion for users and it also unnecessarily increases the complexity and

gas costs of the contract.


-----

#### Recommendation

The contract should be updated to either make use of the liquidity mechanism or remove

the redundant code.

1. If the intention is to use the liquidity mechanism, the contract should be updated to

allow `liquidityFeeonBuy` and `liquidityFeeonSell` to be set to

non-zero values. This could be done through a function that can be called by the

contract owner or through a mechanism that adjusts the fees based on certain

conditions.

2. If the liquidity mechanism is not needed, the code related to it, including the

calculation of `liquidityShare` and the call to `swapAndLiquify, should be`

removed from the contract. This will simplify the contract and reduce gas costs.


-----

