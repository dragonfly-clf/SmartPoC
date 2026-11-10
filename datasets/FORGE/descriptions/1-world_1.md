#### MWV - Multisig Wallet Vulnerability

**Criticality** Critical

**Location** contracts/WorldToken.sol

**Status** Unresolved

#### Description

The implementation of the multisig wallet functionality in the contract grants any authorized

owner the authority to add or remove authorized wallets by utilizing the `addOwner` and

`removeOwner` methods, respectively. This is possible due to the mutability of

`numConfirmationsRequired` variable, as described in detail at the MWR section.

However, this approach poses a significant security vulnerability. If any of the authorized

owners' wallet is compromised, an attacker could exploit this situation by removing all other

authorized wallets and executing any proposal without legitimate authorization.

#### Recommendation

The team should carefully manage the private keys of the owner’s and authorized owners'

accounts.


-----

