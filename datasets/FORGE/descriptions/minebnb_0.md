#### ST - Stops Transactions

**Criticality** Critical

**Location** MineBNB.sol#L468,479,484,489,532

**Status** Renounced

#### Description

The contract owner has the authority to stop the transactions for all users excluding the

authorized users. The owner may take advantage of it by either setting the

  - `tradingOpen` to false.

  - `_maxWalletToken` to zero.

  - `cooldownTimerInterval` to a large value.

  - `_maxTxAmount` to zero.


-----

The contract owner has the authority to stop the sales for all users excluding the authorized

users. The owner may take advantage of it by setting the `sellMultiplier` to a high

value. As a result, the contract may operate as a honeypot.
```
 uint256 multiplier = isSell ? sellMultiplier : 100;
 uint256 feeAmount =
 amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);

#### Recommendation

```
The contract could embody a check for not allowing setting the `_maxTxAmount` less

than a reasonable amount. A suggested implementation could check that the maximum

amount should be more than a fixed percentage of the total supply. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a

powerful security mechanism that will prevent a single user from accessing the contract

admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-signature wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6](https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6f060f3f5a7)


[f060f3f5a7.](https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6f060f3f5a7)


However, the contract's authorized addresses still have the authority to set the


`_maxTxAmount` to zero.


-----

