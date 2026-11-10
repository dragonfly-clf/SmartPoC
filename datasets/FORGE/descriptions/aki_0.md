##### BC - Blacklisted Contracts

###### Criticality high

 Location https://bscscan.com/address/0x3d8114ea0210237ba04830c8c2c36c663ab2f772#c ode#L1691

 Description

 The contract owner has the authority to stop contracts from transactions. The owner may take advantage of it by adding an address to the automatedMarketMakerPairs list and setting the maxSellTransactionAmount to zero.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x3d8114ea0210237ba04830c8c2c36c663ab2f772#c ode#L1691|

```
if(
  !swapping &&
  automatedMarketMakerPairs[to] && // sells only by detecting transfer to
automated market maker pair
  from != address(pancakeswapV2Router) && //router -> pair is removing
liquidity which shouldn't have max
  !_isExcludedFromFees[to] //no max for those excluded from fees
) {
  require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds
the maxSellTransactionAmount.");
}

```

###### Recommendation

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.