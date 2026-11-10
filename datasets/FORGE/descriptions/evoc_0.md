#### ST - Stops Transactions


#### Description


The contract owner has the authority to stop the transactions for all users excluding the


owner. The owner may take advantage of it by setting the `_maxTxAmount` to zero.


-----

7


#### Recommendation


The contract could embody a check for not allowing setting the _maxTxAmount less than a


reasonable amount. A suggested implementation could check that the maximum amount


should be more than a fixed percentage of the total supply. The team should carefully

manage the private keys of the owner’s account. We strongly recommend a powerful

security mechanism that will prevent a single user from accessing the contract admin


functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

8


#### Team Update


The team responded with the following statement:


_“We added this feature because it is necessary to pause the trade before completing our_


_presale. Our project has gone through a hard fork, a contract update and all previous_


_investors have already received their coins. This function was added precisely to prevent_


_other people from adding liquidity to our contract before the token launch, as they already_


_have the new coins in their wallets, avoiding harming our official launch!!”_


-----

9


