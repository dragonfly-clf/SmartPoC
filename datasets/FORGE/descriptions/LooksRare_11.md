12. tokenId and amount fully controlled by the order strategy when matching two orders|Col2|
|---|---|
|Severity: Informational|Difficulty: High|
|Type: Data Validation|Finding ID: TOB-LR-12|
|Target: contracts/LooksRareExchange.sol||


#### Description
When two orders are matched, the strategy defined by the MakerOrder is called to check
whether the order can be executed.
```
 function matchAskWithTakerBidUsingETHAndWETH (
   OrderTypes.TakerOrder calldata takerBid,
   OrderTypes.MakerOrder calldata makerAsk
 ) external payable override nonReentrant {
   [...]
   // Retrieve execution parameters
   ( bool isExecutionValid, uint256 tokenId, uint256 amount ) =
 IExecutionStrategy(makerAsk.strategy)
     .canExecuteTakerBid(takerBid, makerAsk);
   require (isExecutionValid, "Strategy: Execution invalid" );
   [...]
 }

```
_Figure 12.1: matchAskWithTakerBidUsingETHAndWETH_

_( LooksRareExchange.sol#186-212 )_

The strategy call returns a boolean indicating whether the order match can be executed,
the tokenId to be sold, and the amount to be transferred. The LooksRareExchange
contract does not verify these last two values, which means that the strategy has full
control over them.

Trail of Bits 37 LooksRare Security Assessment


-----

_Figure 12.2: matchAskWithTakerBidUsingETHAndWETH_

_( LooksRareExchange.sol#217-228 )_

This ultimately means that a faulty or malicious strategy can cause a loss of funds (e.g., by
returning a different tokenId from the one that was intended to be sold or bought).

Trail of Bits 38 LooksRare Security Assessment


-----

Additionally, this issue may become problematic if strategies become trustless and are no
longer developed or allowlisted by the LooksRare team.

#### Exploit Scenario
A faulty strategy, which returns a different tokenId than expected, is allowlisted in the
protocol. Alice creates a new order using that strategy to sell one of her tokens. Bob
matches Alice’s order, but because the tokenId is not validated before executing the
order, he gets a different token than he intended to buy.

#### Recommendations
Short term, evaluate and document this behavior and use this documentation when
integrating new strategies into the protocol.

Long term, consider adding further safeguards to the LooksRareExchange contract to
check the validity of the tokenId and the amount returned by the call to the strategy.

Trail of Bits 39 LooksRare Security Assessment


-----

|