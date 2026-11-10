8. Missing event for a critical operation|Col2|
|---|---|
|Severity: Low|Difficulty: Low|
|Type: Auditing and Logging|Finding ID: TOB-LR-8|
|Target: contracts/LooksRareExchange.sol||


#### Description
The system does not emit an event when a protocol fee is levied in the
```
 _transferFeesAndFunds and _transferFeesAndFundsWithWETH functions.

```
Operations that transfer value or perform critical operations should trigger events so that
users and off-chain monitoring tools can account for important state changes.
```
 if ((protocolFeeRecipient != address (0)) && (protocolFeeAmount != 0)) {
   IERC20(currency).safeTransferFrom(from, protocolFeeRecipient, protocolFeeAmount);
   finalSellerAmount -= protocolFeeAmount;
 }

```
_Figure 8.1: Protocol fee transfer in _transferFeesAndFunds function_
_( contracts/executionStrategies/StrategyDutchAuction.sol#L440-L443 )_

#### Exploit Scenario
A smart contract wallet provider has a LooksRare integration that enables its users to buy
and sell NFTs. The front end relies on information from LooksRare’s subgraph to itemize
prices, royalties, and fees. Because the system does not emit an event when a protocol fee
is incurred, an under-calculation in the wallet provider’s accounting leads its users to
believe they have been overcharged.

#### Recommendations
Short term, add events for all critical operations that transfer value, such as when a
protocol fee is assessed. Events are vital aids in monitoring contracts and detecting
suspicious behavior.

Long term, consider adding or accounting for a new protocol fee event in the LooksRare
subgraph and any other off-chain monitoring tools LooksRare might be using.

Trail of Bits 32 LooksRare Security Assessment


-----

|