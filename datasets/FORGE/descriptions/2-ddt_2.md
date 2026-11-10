#### PVC - Price Volatility Concern

|Criticality|minor|
|---|---|
|Location|DiamondDexToken.sol#L1195|
|Status|renounced|


##### Description


The numTokensSellToAddToLiquidity could produce a dramatically price volatility. If
the variable set to a high number, then the contract will sell a huge amount of
tokens in a single transaction.


##### Recommendation


The contract could ensure that it will not sell more than a reasonable amount of
tokens once. A suggested implementation could check that the maximum amount
should be less than a fixed percentage of the total supply.


##### Team Update


The team renounced ownership in the following transaction:
[https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)
[d653cca5c0389219](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)


The amount of tokens to add to liquidity is locked at 0.000001% of the totalSupply.


-----

