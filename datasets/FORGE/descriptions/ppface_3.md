#### PTRP - Potential Transfer Revert Propagation

**Criticality** Minor / Informative

**Location** Token.sol#L454,459,483

**Status** Unresolved

#### Description

The contract sends funds to `contestReceiver` and `marketingAddress` as part

of the transfer flow. These address can either be a wallet address or a contract. If the

addresses belongs to a contract then it may revert from incoming payment. As a result, the

error will propagate to the token’s contract and revert the transfer.
```
 if (contestFee > 0) {
   success,) = contestReceiver.call{value: amountETHContest,
 gas: 35000}("");
   require(success, "Failed to send ETH to contest receiver");
 }
 if (marketingFee > 0) {
   (success,) = marketingAddress.call{value:
 amountETHMarketing, gas: 35000}("");
   require(success, "Failed to send ETH to marketing fee
 receiver");
 }
 ...
 (success,) = marketingAddress.call{value: amountETH, gas:
 35000}("");
 require(success, "Failed to send ETH to marketing fee
 receiver");

#### Recommendation

```
The contract should tolerate the potential revert from the underlying contracts when the

interaction is part of the main transfer flow. This could be achieved by not allowing set

contract addresses or by sending the funds in a non-revertable way.


-----

