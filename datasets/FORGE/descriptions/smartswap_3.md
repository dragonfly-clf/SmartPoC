#### MTP - Misleading Token Parameter

**Criticality** Minor / Informative

**Location** DP2PCoin.sol#L709

**Status** Unresolved

#### Description

The contract uses the `startDeal` function that accepts a `DealData` struct as an

input parameter. This struct includes the variable `deal.token . The` `startDeal`

function is designed to work with native tokens (e.g., Ethereum's ETH) given the use of

`msg.value` to handle transactions. As such, the function does not utilize the

`deal.toke n variable when initiating a deal. The inclusion of` `deal.token` in the

parameters leads to a discrepancy between the function's intended use and its parameters,

potentially causing confusion for users. They may assume that `deal.token` should be

specified, even though it has no impact on the transaction, and could set this parameter

when initiating a deal with native tokens.
```
   function startDeal(
      DealData calldata deal
   ) external payable override onlySeller(deal) returns
 (bytes32) {
      bytes32 _hash = dealHash(deal);
      require(deals[_hash] == DealState.ZERO, 'storage slot
 collision');
      require(msg.value > 0 && msg.value == deal.amount +
 deal.fee, 'wrong ether amount');
      deals[_hash] = DealState.START;
      emit StateChanged(_hash, deal, DealState.START,
 msg.sender);
      return _hash;
   }

#### Recommendation

```
It is recommended to refactor the `startDeal` function to remove the `deal.token`

parameter, as it is not applicable for transactions with native tokens. This will streamline the

function interface, reducing confusion and preventing users from providing an unnecessary


-----

and unused parameter. The refactored function should clearly indicate through its

parameters and documentation that it is intended for use with native tokens only, thus

eliminating any ambiguity regarding the purpose and usage of the `deal.token` variable.

This change will enhance the contract's usability and ensure that the function's parameters

are in full alignment with its logic.


-----

