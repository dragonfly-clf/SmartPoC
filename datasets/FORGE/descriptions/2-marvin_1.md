#### BT - Burns Tokens

**Criticality** Critical

**Location** MarvinInu.sol#L1183,1302

**Status** Unresolved

#### Description

The contract automatically burns up to 10% of the liquidity pair token balance every 10

minutes at most. If a large amount of liquidity is removed from the pool through burning, it

can cause a decrease in the liquidity of the pool, which can, in turn, result in increased

volatility and price fluctuations of the tokens in the pair.
```
 if(!swapping && automatedMarketMakerPairs[to] && lpBurnEnabled
 && block.timestamp >= lastLpBurnTime + lpBurnFrequency &&
 !_isExcludedFromFees[from]){
     autoBurnLiquidityPairTokens();
     }
   function setAutoLPBurnSettings(uint256 _frequencyInSeconds,
 uint256 _percent, bool _Enabled) external onlyOwner {
      require(_frequencyInSeconds >= 600, "cannot set buyback
 more often than every 10 minutes");
      require(_percent <= 1000 && _percent >= 0, "Must set
 auto LP burn percent between 0% and 10%");
      lpBurnFrequency = _frequencyInSeconds;
      percentForLPBurn = _percent;
      lpBurnEnabled = _Enabled;
   }

#### Recommendation

```
It is recommended to review and adjust the parameters of the auto-liquidity burn

mechanism to ensure that it operates optimally. Specifically, the period of time and

percentage burned should be reasonable and appropriate for the specific use case. This will

help to prevent any potential issues and ensure that the mechanism functions as intended.


-----

The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

