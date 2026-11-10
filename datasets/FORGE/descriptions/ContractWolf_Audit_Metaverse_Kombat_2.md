##### SWC-103 | Divide Before Multiply

```
EachPer=100/(_LiquidityBuyPer.add(_marketingBuyPer).add(_RewardBuyPer));

```
```
MarketingPer=EachPer*_marketingBuyPer;

```
```
RewardPer=EachPer*_RewardBuyPer;

```
```
}

```
```
EachPer=100/(_LiquiditySellPer.add(_marketingSellPer).add(_RewardSellPer));
       MarketingPer=EachPer*_marketingSellPer;
       RewardPer=EachPer*_RewardSellPer;
    }

```
From function swapAndLiquify performs a multiplication on the result of a division

**Recommendation**
Performing multiplication before division is generally better to avoid loss of precision

```
   }
   else{
EachPer=100/(_LiquiditySellPer.add(_marketingSellPer).add(_RewardSellPer));
     MarketingPer=EachPer*_marketingSellPer;
     RewardPer=EachPer*_RewardSellPer;
   }

```
From function swapAndLiquify performs a multiplication on the result of a division

**Recommendation**
Performing multiplication before division is generally better to avoid loss of precision


-----

