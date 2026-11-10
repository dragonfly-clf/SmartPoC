4. Users that create ask orders cannot modify minPercentageToAsk|Col2|
|---|---|
|Severity: Low|Difficulty: Medium|
|Type: Data Validation|Finding ID: TOB-LR-4|
|Target: contracts/LooksRareExchange.sol||


#### Description
Users who sell their NFTs on LooksRare are unable to protect their orders against arbitrary
changes in royalty fees set by NFT collection owners; as a result, users may receive less of a
sale’s value than expected.

Ideally, when a user lists an NFT, he should be able to set a threshold at which the
transaction will execute based on the amount of the sale’s value that he will receive. This
threshold is set via the minPercentageToAsk variable in the MakerOrder and
```
 TakerOrder structs. The minPercentageToAsk variable protects users who create ask

```
orders from excessive royalty fees. When funds from an order are transferred, the
```
 LooksRareExchange contract ensures that the percentage amount that needs to be

```
transferred to the recipient is greater than or equal to minPercentageToAsk (figure 3.1).
```
 function _transferFeesAndFunds (
   address strategy,
   address collection,
   uint256 tokenId,
   address currency,
   address from,
   address to,
   uint256 amount,
   uint256 minPercentageToAsk
 ) internal {
   // Initialize the final amount that is transferred to seller
   uint256 finalSellerAmount = amount;
   // 1. Protocol fee
   {
      uint256 protocolFeeAmount = _calculateProtocolFee(strategy, amount);
      [...]
        finalSellerAmount -= protocolFeeAmount;
      }
   }

```
Trail of Bits 25 LooksRare Security Assessment


-----

However, users creating ask orders cannot modify minPercentageToAsk . By default, the
```
 minPercentageToAsk of orders placed through the LooksRare platform is set to 85%. In

```
cases in which there is no royalty fee and the protocol fee is 2%, minPercentageToAsk
could be set to 98%.

#### Exploit Scenario
Alice lists an NFT for sale on LooksRare. The protocol fee is 2%, minPercentageToAsk is
85%, and there is no royalty fee. The NFT project grows in popularity, which motivates Eve,
the owner of the NFT collection, to raise the royalty fee to 9.5%, the maximum fee allowed
by the RoyaltyFeeRegistry contract. Bob purchases Alice’s NFT. Alice receives 89.5% of
the sale even though she could have received 98% of the sale at the time of the listing.

#### Recommendations
Short term, set minPercentageToAsk to 100% minus the sum of the protocol fee and the
max value for a royalty fee, which is 9.5%.

Long term, identify and validate the bounds for all parameters and variables in the smart
contract system.

Trail of Bits 26 LooksRare Security Assessment


-----

|