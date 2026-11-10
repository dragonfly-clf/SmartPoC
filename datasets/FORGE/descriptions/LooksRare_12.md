13. Risk of phishing due to data stored in maker order params field|Col2|
|---|---|
|Severity: Informational|Difficulty: Low|
|Type: Data Validation|Finding ID: TOB-LR-13|
|Target: LooksRare/contracts/||


#### Description
The MakerOrder struct contains a params field, which holds arbitrary data for each
strategy. This storage of data may increase the chance that users could be phished.
```
 struct MakerOrder {
   bool isOrderAsk; // true --> ask / false --> bid
   address signer; // signer of the maker order
   address collection; // collection address
   uint256 price; // price (used as )
   uint256 tokenId; // id of the token
   uint256 amount; // amount of tokens to sell/purchase (must be 1 for ERC721, 1+ for
 ERC1155)
   address strategy; // strategy for trade execution (e.g., DutchAuction,
 StandardSaleForFixedPrice)
   address currency; // currency (e.g., WETH)
   uint256 nonce; // order nonce (must be unique unless new maker order is meant to
 override existing one e.g., lower ask price)
   uint256 startTime; // startTime in timestamp
   uint256 endTime; // endTime in timestamp
   uint256 minPercentageToAsk; // slippage protection (9000 --> 90% of the final price must
 return to ask)
   bytes params; // additional parameters
   uint8 v; // v: parameter (27 or 28)
   bytes32 r; // r: parameter
   bytes32 s; // s: parameter
 }

```
_Figure 13.1: The MakerOrder struct in contracts/libraries/OrderTypes.sol#L12-29_

In the Dutch auction strategy, the maker params field defines the start price for the
auction. When a user generates the signature, the UI must specify the purpose of params .
```
 function canExecuteTakerBid (OrderTypes.TakerOrder calldata takerBid, OrderTypes.MakerOrder
 calldata makerAsk)
   external
   view

```
Trail of Bits 40 LooksRare Security Assessment


-----

_Figure 13.2: The canExecuteTakerBid function in_
```
    contracts/executionStrategies/StrategyDutchAuction.sol#L39-L70

```
When used in a StrategyPrivateSale transaction, the params field holds the buyer
address that the private sale is intended for.
```
 function canExecuteTakerBid(OrderTypes.TakerOrder calldata takerBid, OrderTypes.MakerOrder
 calldata makerAsk)
   external
   view
   override
   returns (
     bool,
     uint256,
     uint256
   )
 {
   // Retrieve target buyer
   address targetBuyer = abi.decode(makerAsk.params, ( address ));
   return (
     ((targetBuyer == takerBid.taker) &&
        (makerAsk.price == takerBid.price) &&
        (makerAsk.tokenId == takerBid.tokenId) &&
        (makerAsk.startTime <= block.timestamp ) &&
        (makerAsk.endTime >= block.timestamp )),
     makerAsk.tokenId,
     makerAsk.amount
   );
 }

```
_Figure 13.3: The canExecuteTakerBid function in_
```
      contracts/executionStrategies/StrategyPrivateSale.sol

```
Trail of Bits 41 LooksRare Security Assessment


-----

#### Exploit Scenario
[Alice receives an EIP-712 signature request through MetaMask. Because the value is](https://eips.ethereum.org/EIPS/eip-712)
masked in the params field, Alice accidentally signs an incorrect parameter that allows an
attacker to match.

#### Recommendations
Short term, document the expected values for the params value for all strategies and add
in-code documentation to ensure that developers are aware of strategy expectations.

Long term, document the risks associated with off-chain signatures and always ensure that
users are aware of the risks of signing arbitrary data.

Trail of Bits 42 LooksRare Security Assessment


-----

|