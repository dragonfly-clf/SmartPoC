#### RFA - Redundant Fees Accumulation

**Criticality** Minor / Informative

**Location** MitaoCat.sol#L448

**Status** Unresolved

#### Description

The contract accumulates the collected fees in a variable called `tokensForOperations .`

This variable is private so it is not visible to the users. Additionally, it is accessed and reset

in the swap method but it is not used in a meaningful way. As a result, it increases

unnecessarily the gas consumption and decreases the code readability.
```
 if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
   sellFees memory sellFee = _sellFees[currentTID];
   fees = amount * sellTotalFees / 100;
   tokensForOperations += fees * sellFee.operationsFee /
 sellTotalFees;
 }
 ...
 uint256 totalTokensToSwap = tokensForOperations;
 if(contractBalance == 0 || totalTokensToSwap == 0) {return;}
 if(contractBalance > swapTokensAtAmount * 60){
   contractBalance = swapTokensAtAmount * 60;
 }
 bool success;
 swapTokensForEth(contractBalance);
 tokensForOperations = 0;

#### Recommendation

```
The team is adviced to remove the state variable `tokensForOperations .`


-----

