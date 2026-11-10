#### RPF - Redundant Payable Function

**Criticality** Minor / Informative

**Location** DP2PToken.sol#L394
DP2PTokenLegacy
USDT.sol#L394

**Status** Unresolved

#### Description

The contract's function `startDeal` has a `payable` modifier which means a user

pays with the native token. The function does not use the `msg.value` variable anywhere

inside the function to indicate the usage of the `payable` modifier. As a result, the

`payable` modifier is redundant.
```
   function startDeal(
      DealData calldata deal
   ) external payable virtual override onlySeller(deal)
 returns (bytes32) {
      bytes32 _hash = dealHash(deal);
      require(deals[_hash] == DealState.ZERO, 'storage slot
 collision');
      deals[_hash] = DealState.START;
      _transferFrom(deal.token, deal.seller, address(this),
 deal.amount + deal.fee);
      emit StateChanged(_hash, deal, DealState.START,
 msg.sender);
      return _hash;
   }

#### Recommendation

```
The team is advised to remove the `payable` modifier from the function's declaration as

it is not needed.


-----

