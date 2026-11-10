#### ST - Stops Transactions

**Criticality** Critical

**Location** JIMBOY.sol#L319,323,326

**Status** Renounced

#### Description

The contract owner has the authority to stop the transactions for all users excluding the

owner. The owner may take advantage of it by setting either the `tradingOpen` to false

or the `_maxTxAmount` to zero.
```
 if (!tradingOpen) {
   require(from == owner(), "TOKEN: This account cannot send tokens until
 trading is enabled");
 }
 require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");

```
The contract owner has the authority to stop the sales for all users excluding the owner. The

owner may take advantage of it by setting either the `_maxWalletSize` to zero or the

sell fees to a value greater than 100. As a result, the contract may operate as a honeypot.


-----

#### Recommendation

The contract could embody a check for not allowing setting the `_maxTxAmount` and

`_maxWalletSize` less than a reasonable amount. A suggested implementation could

check that the minimum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a8](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


[2d0ac33fb2d.](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


-----

