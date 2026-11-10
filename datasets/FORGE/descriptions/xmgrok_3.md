#### PTRP - Potential Transfer Revert Propagation

**Criticality** Minor / Informative

**Location** XMasGrok.sol#L304

**Status** Unresolved

#### Description

The contract sends funds to a `_marketingAddress` and `_developmentAddress`

as part of the transfer flow. These addresses can either be a wallet address or a contract. If

the address belongs to a contract then it may revert from incoming payment. As a result,

the error will propagate to the token’s contract and revert the transfer.
```
 function sendETHToFee(uint256 amount) private {
   _developmentAddress.transfer(amount.div(2));
   _marketingAddress.transfer(amount.div(2));
 }

#### Recommendation

```
The contract should tolerate the potential revert from the underlying contracts when the

interaction is part of the main transfer flow. This could be achieved by not allowing set

contract addresses or by sending the funds in a non-revertable way.


-----

