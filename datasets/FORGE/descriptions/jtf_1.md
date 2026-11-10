#### OCTD - Transfers Contract's Tokens

**Criticality** Critical

**Location** JETFINDER.sol#L1185

**Status** Unresolved

#### Description

The contract owner has the authority to claim all the balance of the contract. The owner

may take advantage of it by calling the `swapBack` function as part of the transfer flow.

The `tokensForLiquidity` and `tokensForMarketing` accumulates tokens that

are meant to be swapped. If the owner enables the `rescueSwap` variable, then the

contract will transfer all of its tokens to the `marketingWallet` address. The contract's

balance will become zero, but the contract does not reset the `tokensForLiquidity`

and `tokensForMarketing` variables back to zero. Afterwards, if the owner sets the

`rescueSwap` to false, then these variables will have an amount greater than the contract's

balance actual amount. The owner can utilize the `resetTaxAmount` function to reset

the `tokensForLiquidity` and `tokensForMarketing . However, if the owner`

does not utilize the `resetTaxAmount` function the transaction will revert.


-----

#### Recommendation

The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-signature wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

