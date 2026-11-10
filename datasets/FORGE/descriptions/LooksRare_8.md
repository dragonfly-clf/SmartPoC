9. Taker orders are not EIP-712 signatures|Col2|
|---|---|
|Severity: Informational|Difficulty: High|
|Type: Data Validation|Finding ID: TOB-LR-9|
|Target: contracts/libraries/OrderTypes.sol||


#### Description
When takers attempt to match order proposals, they are presented with an obscure blob of
data. In contrast, makers are presented with a formatted data structure that makes it
easier to validate transactions.
```
 struct TakerOrder {
   bool isOrderAsk ; // true --> ask / false --> bid
   address taker ; // msg.sender
   uint256 price ; // final price for the purchase
   uint256 tokenId ;
   uint256 minPercentageToAsk ; // // slippage protection (9000 --> 90% of the final price
 must return to ask)
   bytes params ; // other params (e.g., tokenId)
 }

```
_Figure 9.1: The TakerOrder struct in OrderTypes.sol :31-38_

While this issue cannot be exploited directly, it creates an asymmetry between the user
experience (UX) of makers and takers. Because of this, users depend on the information
that the user interface (UI) displays to them and are limited by the UX of the wallet software
they are using.

#### Exploit Scenario 1
Eve, a malicious user, lists a new collection with the same metadata as another, more
popular collection. Bob sees Eve’s listing and thinks that it is the legitimate collection. He
creates an order for an NFT in Eve’s collection, and because he cannot distinguish the
parameters of the transaction he is signing, he matches it, losing money in the process.

#### Exploit Scenario 2
Alice, an attacker, compromises the UI, allowing her to manipulate the information
displayed by it in order to make illegitimate collections look legitimate. This is a more
extreme exploit scenario.

Trail of Bits 33 LooksRare Security Assessment


-----

#### Recommendations
Short term, evaluate and document the current UI and the pitfalls that users might
encounter when matching and creating orders.

[Long term, evaluate whether adding support for EIP-712 signatures in TakerOrder would](https://eips.ethereum.org/EIPS/eip-712)
minimize the issue and provide a better UX.

Trail of Bits 34 LooksRare Security Assessment


-----

|