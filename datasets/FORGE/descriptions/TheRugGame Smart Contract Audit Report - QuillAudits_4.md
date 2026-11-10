2. _buyAndBurnToken and _rugLoser susceptible to Frontrun attacks

 Description

 _buyAndBurnToken() function in susceptible to Frontrun attack. This is because the _amountOutMin parameter is set to 0. This is not recommended as this results in 100% slippage and can be frontrunned by attackers and bots especially in a low liquidity pool. 
 Similarly _rugLoser() function is susceptible to frontrun attack (see line: 242).
 For example, a sandwich attack is possible(which consists of a frontrun and a backrun) to snipe funds from a swap by placing a buy order(with higher gas price) before the user's order and a sell order after the user's order. This would result in the attacker buying at a low price, which results in a costlier trade for the user and then selling at a slightly higher price after the user's trade.
 This attack is significant especially in the trades that are larger in size/amount. So here it would mean the transfers of large amounts of THERUGGAME tokens while buying and selling them.

 Recommendation

 It is advised to set appropriate values for _amountOutMin. Setting it as zero is not recommended as it results in 100% slippage which is most susceptible to frontrun attacks. Review business and operational logic.

 Refer

 CoinMarketCap Medium

 Additional resource

 https://medium.com/mstable/solving-the-issue-with-slippage-in-eip-4626-3af9a5d8e597

 Status

 Resolved

 Comment: The function slippage() was added to set the minimum amount to avoid 100 percent slippage, and is being passed as a parameter in the respective functions.


-----

###### Low Severity Issues

 