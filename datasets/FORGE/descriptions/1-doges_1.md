#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L874

##### Description

The contract owner receives all the funds from either the swap and liquify feature or
by manually calling the process_Tokens_Now. These funds have been accumulated
from fees collected from the contract. If there are a lot of accumulated fees this will
significantly decrease the token’s price.

|Criticality|minor|
|---|---|
|Location|contract.sol#L874|

```
swapTokensForBNB(contractTokenBalance);
uint256 contractBNB = address(this).balance;
sendToWallet(Wallet_Dev,contractBNB);

```

##### Recommendation

The contract could embody a check for not liquefying and sending to the contract
owners more than a reasonable amount. The contract could implement a feature
that works as a balancer, like auto generated liquidity or buyback.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected on 7th March 2022

The team has renounced ownership and the threat is no longer applicable.


-----

